import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohasunno/models/campaign_data.dart';

void main() {
  test('Campaign worlds and levels banner assets verification', () {
    final worlds = CampaignCatalog.getAllWorlds();
    expect(worlds.length, 4);

    for (final world in worlds) {
      // 1. Verify world banner file exists
      final worldFile = File(world.bannerPath);
      expect(worldFile.existsSync(), isTrue, reason: "World banner ${world.bannerPath} missing");

      // 2. Verify all level banners in this world exist
      for (final level in world.levels) {
        final levelFile = File(level.bannerPath);
        expect(levelFile.existsSync(), isTrue, reason: "Level banner ${level.bannerPath} for ${level.code} missing");
      }
    }
  });
}
