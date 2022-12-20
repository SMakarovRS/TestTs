﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ОпределенияСервиса(МестоположениеWSDL, ОписательОшибки, ТаймаутПодключения = -1) Экспорт
	
	Определения = Подключение1СТакском.НовыйОпределенияСервиса(
		МестоположениеWSDL,
		,
		ТаймаутПодключения);
	
	Если НЕ ПустаяСтрока(Определения.КодОшибки) Тогда
		ОписательОшибки = Определения;
		ВызватьИсключение Определения.СообщениеОбОшибке;
	КонецЕсли;
	
	Возврат Определения;
	
КонецФункции

#КонецОбласти