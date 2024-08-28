import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNotifier extends StateNotifier<List<String>> {
  NotificationNotifier() : super([]);

  // Lisää uusi ilmoitus
  void addNotification(String notification) {
    state = [...state, notification];
  }

  // Tyhjennä kaikki ilmoitukset
  void clearNotifications() {
    state = [];
  }

  // Tarkista rajojen ylitykset ja luo ilmoitukset
  void checkThresholds(
      double minTemp, double maxTemp, double minHumidity, double maxHumidity,
      {double? latestTemperature, double? latestHumidity}) {
    state = [];

    // Tarkistetaan, onko viimeisin lämpötila määritelty ja ylittyykö raja
    if (latestTemperature != null) {
      if (latestTemperature < minTemp || latestTemperature > maxTemp) {
        addNotification('Lämpötilan raja ylittyi!');
      }
    }

    // Tarkistetaan, onko viimeisin kosteus määritelty ja ylittyykö raja
    if (latestHumidity != null) {
      if (latestHumidity < minHumidity || latestHumidity > maxHumidity) {
        addNotification('Kosteusprosentin raja ylittyi!');
      }
    }

    // Mahdolliset yleiset rajat (esim. epärealistiset arvot)
    if (minTemp < -50 || maxTemp > 50) {
      addNotification("Lämpötila-arvo ylittää sallitun rajan!");
    }
    if (minHumidity < 0 || maxHumidity > 100) {
      addNotification("Kosteusarvo ylittää sallitun rajan!");
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<String>>((ref) {
  return NotificationNotifier();
});
