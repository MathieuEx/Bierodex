import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'account_screen.dart';
import 'barcode_scanner_screen.dart';
import 'my_collection_tab.dart';
import 'search_screen.dart';
import 'stats_screen.dart';
import 'styles_tab.dart';
import 'world_map_screen.dart';

/// Coquille principale : une barre de navigation en bas d'écran, à portée
/// de pouce, avec des libellés explicites. Les onglets sont gardés en vie
/// dans un `IndexedStack` pour conserver leur état (position de la carte,
/// défilement, filtres) quand on passe de l'un à l'autre.
///
/// Le scanner n'est pas un onglet : c'est une action ponctuelle en plein
/// écran, mise en avant au centre de la barre.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _scanIndex = 2;

  int _index = 0;

  void _onDestinationSelected(int index) {
    if (index == _scanIndex) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
      return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          WorldMapScreen(),
          _CollectionPage(),
          SizedBox.shrink(), // Scanner : ouvert en plein écran.
          _StylesPage(),
          AccountScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.public_outlined),
            selectedIcon: const Icon(Icons.public),
            label: l10n.navMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_bar_outlined),
            selectedIcon: const Icon(Icons.local_bar),
            label: l10n.navCollection,
          ),
          NavigationDestination(
            icon: const _ScanButton(),
            label: l10n.navScan,
            tooltip: l10n.scanBeer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_drink_outlined),
            selectedIcon: const Icon(Icons.local_drink),
            label: l10n.styles,
          ),
          NavigationDestination(
            icon: ListenableBuilder(
              listenable: AuthService.instance,
              builder: (context, _) => Icon(
                AuthService.instance.isSignedIn
                    ? Icons.person
                    : Icons.person_outline,
              ),
            ),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

/// Pastille en dégradé or → orange cerclée de bleu ciel, comme le lettrage
/// du logo : l'action principale se repère d'un coup d'œil.
class _ScanButton extends StatelessWidget {
  const _ScanButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppGradients.amber,
        borderRadius: BorderRadius.circular(AppTheme.radiusControl),
        border: Border.all(color: AppColors.sky, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.qr_code_scanner,
        color: AppColors.night,
        size: 24,
      ),
    );
  }
}

/// Collection et statistiques vont ensemble : les stats sont une lecture
/// de la collection, accessibles depuis sa barre de titre.
class _CollectionPage extends StatelessWidget {
  const _CollectionPage();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collectionTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () =>
                showSearch(context: context, delegate: BeerSearchDelegate()),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: l10n.statsTitle,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
        ],
      ),
      body: const MyCollectionTab(),
    );
  }
}

class _StylesPage extends StatelessWidget {
  const _StylesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.stylesTitle)),
      body: const StylesTab(),
    );
  }
}
