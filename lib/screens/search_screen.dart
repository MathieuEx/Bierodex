import 'package:flutter/material.dart';

import '../data/beer_styles.dart';
import '../data/beers.dart';
import '../data/countries.dart';
import '../models/beer.dart';
import '../models/beer_style.dart';
import '../theme/app_theme.dart';
import '../utils/text_normalize.dart';
import '../widgets/beer_tile.dart';
import '../l10n/l10n.dart';

enum _SortOption {
  relevance,
  nameAsc,
  abvAsc,
  abvDesc;

  String get label => switch (this) {
    relevance => L10n.current.sortRelevance,
    nameAsc => L10n.current.sortNameAsc,
    abvAsc => L10n.current.sortAbvAsc,
    abvDesc => L10n.current.sortAbvDesc,
  };
}

/// État des filtres et du tri de la recherche. Un [ChangeNotifier] partagé
/// entre le champ de requête (le [BeerSearchDelegate]) et la feuille de
/// filtres, pour que modifier un filtre reconstruise immédiatement les
/// résultats affichés.
class _SearchFilters extends ChangeNotifier {
  BeerFamily? family;
  String? styleId;
  String? country;
  double minAbv = 0;
  double maxAbv = 20;
  _SortOption sort = _SortOption.relevance;

  bool get isActive =>
      family != null ||
      styleId != null ||
      country != null ||
      minAbv > 0 ||
      maxAbv < 20;

  void apply({
    required BeerFamily? family,
    required String? styleId,
    required String? country,
    required double minAbv,
    required double maxAbv,
    required _SortOption sort,
  }) {
    this.family = family;
    this.styleId = styleId;
    this.country = country;
    this.minAbv = minAbv;
    this.maxAbv = maxAbv;
    this.sort = sort;
    notifyListeners();
  }
}

class BeerSearchDelegate extends SearchDelegate<void> {
  final _filters = _SearchFilters();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    AnimatedBuilder(
      animation: _filters,
      builder: (context, _) => IconButton(
        icon: Icon(
          _filters.isActive ? Icons.filter_alt : Icons.filter_alt_outlined,
          color: _filters.isActive ? AppColors.amber : null,
        ),
        tooltip: context.l10n.filterAndSort,
        onPressed: () => _openFilters(context),
      ),
    ),
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildBody();

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody();

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _filters,
      builder: (context, _) => _SearchResults(query: query, filters: _filters),
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersSheet(filters: _filters),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final _SearchFilters filters;

  const _SearchResults({required this.query, required this.filters});

  @override
  Widget build(BuildContext context) {
    final q = normalizeForSearch(query.trim());
    final results = beers.where((Beer b) {
      final style = findStyleById(b.styleId);
      if (q.isNotEmpty) {
        final matches =
            normalizeForSearch(b.name).contains(q) ||
            normalizeForSearch(b.brewery).contains(q) ||
            normalizeForSearch(b.country).contains(q) ||
            normalizeForSearch(countryName(b.country)).contains(q) ||
            (style != null && normalizeForSearch(style.name).contains(q));
        if (!matches) return false;
      }
      if (filters.family != null && style?.family != filters.family) {
        return false;
      }
      if (filters.styleId != null && b.styleId != filters.styleId) {
        return false;
      }
      if (filters.country != null && b.country != filters.country) {
        return false;
      }
      if (b.abv < filters.minAbv || b.abv > filters.maxAbv) return false;
      return true;
    }).toList();

    switch (filters.sort) {
      case _SortOption.relevance:
        break;
      case _SortOption.nameAsc:
        results.sort((a, b) => a.name.compareTo(b.name));
      case _SortOption.abvAsc:
        results.sort((a, b) => a.abv.compareTo(b.abv));
      case _SortOption.abvDesc:
        results.sort((a, b) => b.abv.compareTo(a.abv));
    }

    if (query.trim().isEmpty && !filters.isActive) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            context.l10n.searchHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noResults,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView(children: results.map((b) => BeerTile(beer: b)).toList());
  }
}

class _FiltersSheet extends StatefulWidget {
  final _SearchFilters filters;

  const _FiltersSheet({required this.filters});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late BeerFamily? _family = widget.filters.family;
  late String? _styleId = widget.filters.styleId;
  late String? _country = widget.filters.country;
  late RangeValues _abvRange = RangeValues(
    widget.filters.minAbv,
    widget.filters.maxAbv,
  );
  late _SortOption _sort = widget.filters.sort;

  void _apply() {
    widget.filters.apply(
      family: _family,
      styleId: _styleId,
      country: _country,
      minAbv: _abvRange.start,
      maxAbv: _abvRange.end,
      sort: _sort,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final stylesInFamily = _family == null
        ? beerStyles
        : stylesForFamily(_family!);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.filterAndSort,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _family = null;
                    _styleId = null;
                    _country = null;
                    _abvRange = const RangeValues(0, 20);
                    _sort = _SortOption.relevance;
                  }),
                  child: Text(context.l10n.reset),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.sortBy.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in _SortOption.values)
                  ChoiceChip(
                    label: Text(option.label),
                    selected: _sort == option,
                    onSelected: (_) => setState(() => _sort = option),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.family.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final family in BeerFamily.values)
                  ChoiceChip(
                    label: Text(family.shortLabel),
                    selected: _family == family,
                    onSelected: (selected) => setState(() {
                      _family = selected ? family : null;
                      if (_styleId != null &&
                          findStyleById(_styleId!)?.family != _family) {
                        _styleId = null;
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.fieldStyle.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final style in stylesInFamily)
                  ChoiceChip(
                    label: Text(style.name),
                    selected: _styleId == style.id,
                    onSelected: (selected) =>
                        setState(() => _styleId = selected ? style.id : null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.fieldCountry.toUpperCase(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final country in allCountries)
                  ChoiceChip(
                    label: Text(countryName(country)),
                    selected: _country == country,
                    onSelected: (selected) =>
                        setState(() => _country = selected ? country : null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.abvValue(
                '${formatDecimal(_abvRange.start)} – '
                '${formatDecimal(_abvRange.end)} %',
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RangeSlider(
              values: _abvRange,
              min: 0,
              max: 20,
              divisions: 40,
              labels: RangeLabels(
                formatDecimal(_abvRange.start),
                formatDecimal(_abvRange.end),
              ),
              onChanged: (values) => setState(() => _abvRange = values),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _apply, child: Text(context.l10n.apply)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
