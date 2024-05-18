class AddEditFormConstants {
  static const addTitle = 'Добавление устройства';
  static const editTitle = 'Редактировать Котел';
  static const connectionError =
      'Не удалось подключиться к устройству. Пожалуйста убедитесь, что введенная информация верна и попробуйте еще раз.';
  static const deviceNameLabel = 'Имя котла';
  static const emptyDeviceNameError = 'Пожалуйста введите имя устройства';
  static const ipFieldLabel = 'IP котла';
  static const emptyIpError = 'Пожалуйста введите IP устройства';
  static const incorrectIpError = 'Пожалуйста введите корректный IP адрес';
  static const usePIDLabel = 'Использовать PID';
  static const forgetThisDeviceLabel = 'Забыть это устройство';
  static const forgetDeviceDialogTitle = 'Удалить котел?';
  static const forgetDeviceDialogBody =
      'Вы уверены что хотите забыть это устройство?';
  static const yes = 'Да';
  static const no = 'Нет';
}

class HomePageConstants {
  static const dashboardHeader = 'Панель управления';
  static const connectionError =
      'Не удалось получить данные с бойлера. Пожалуйста проверьте соединение и попробуйте еще раз.';
  static const noDevicesAdded = 'У Вас пока нет подключенных устройств';
  static const waterHeaterTemperature = 'Темп. теплоносителя';
  static const hotWaterTemperature = 'Темп. горячей воды';
  static const roomTemperature = 'Комнатная температура';
  static const burner = 'Горелка';
  static const on = 'ВКЛ';
  static const off = 'ВЫКЛ';
}

class DevicesPageConstants {
  static const addNewDevice = 'Добавить новое устройство';
}

class NavigationBarConstants {
  static const dashboard = 'Панель управления';
  static const devices = 'Устройства';
  static const graphs = 'Графики';
}

class ManageDevicesPageConstants {
  static const couldNotChangeSettings =
      'Не удалось изменить настройки котла. Пожалуйста проверьте соединения и попробуйте еще раз.';
  static const setTargetTemperature = 'Задать целевую температуру';
  static const normalPreset = 'Стандартная';
  static const hotPreset = 'Горячая';
  static const ecoPreset = 'Eco';
  static const customPreset = 'Задать свою';
  static const customTemperatureTitle = 'Введите температуру';
  static const customTemperatureLabel = 'Температура';
  static const emptyTemperatureError = 'Пожалуйста введите температуру';
  static const negativeTemperatureError =
      'Пожалуйста введите целое положительное число';
  static const submit = 'Задать';
  static const cancel = 'Отмена';
}

class ErrorDialogConstants {
  static const error = 'Ошибка';
}
