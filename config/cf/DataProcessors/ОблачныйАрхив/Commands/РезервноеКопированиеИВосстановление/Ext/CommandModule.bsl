﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Обработки.ОблачныйАрхив.Команды.РезервноеКопированиеИВосстановление: Модуль объекта.
//
////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)

	// Навигационная ссылка:
	//  e1cib/command/Обработка.ОблачныйАрхив.Команда.РезервноеКопированиеИВосстановление.

	ИмяФормы = "Обработка.ОблачныйАрхив.Форма.РезервноеКопированиеИВосстановление"; // Идентификатор

	ОткрытьФорму(
		ИмяФормы,
		Новый Структура,
		ПараметрыВыполненияКоманды.Источник,
		ИмяФормы + ?(ПараметрыВыполненияКоманды.Окно = Неопределено, ".ОтдельноеОкно", ""),
		ПараметрыВыполненияКоманды.Окно);

КонецПроцедуры

#КонецОбласти
