﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	МассивДоступныхВерсий = Новый Соответствие;
	Попытка
		ОбменДаннымиПереопределяемый.ПриПолученииДоступныхВерсийФормата(МассивДоступныхВерсий);
	Исключение
		// Не удалось получить доступные версии формата.
		ВызватьИсключение НСтр("ru = 'В информационной базе не поддерживается синхронизация данных через универсальный формат'");
	КонецПопытки;

	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ВариантОткрытияФормы = ?(Параметры.Свойство("ТолькоЗагрузка"), "ТолькоЗагрузка", "");
	
	Если ВариантОткрытияФормы = "ТолькоЗагрузка" Тогда
		ЭтотОбъект.Заголовок = НСтр("ru = 'Загрузка данных EnterpriseData'");
		Элементы.НадписьЗагрузкаВстроеннойОбработкой.Видимость = Истина;
	Иначе
		Элементы.НадписьЗагрузкаВстроеннойОбработкой.Видимость = Ложь;
		ЭтотОбъект.Заголовок = НСтр("ru = 'Выгрузка и загрузка данных EnterpriseData'");
	КонецЕсли;
	
	МетаОбработкаИмя = ОбработкаОбъект.Метаданные().Имя;
	ЧастиИмени = СтрРазделить(ИмяФормы, ".");
	
	БазовоеИмяДляФормы = "Обработка." + МетаОбработкаИмя;
	ИмяОбработки = ЧастиИмени[1];
	
	Объект.ИсточникВыгрузки = "Отбор";
	
	РазделениеВключено = ОбщегоНазначения.РазделениеВключено();
	
	Если МассивДоступныхВерсий.Количество() = 0 Тогда
		СтрокаПоддерживаемыеВерсииФормата = НСтр("ru = 'Не обнаружены поддерживаемые версии формата'");
		Элементы.ФормаВыполнитьОперацию.Доступность = Ложь;
		Элементы.СтрокаПоддерживаемыеВерсииФормата.ЦветТекста = ЦветаСтиля.ПоясняющийОшибкуТекст;
	Иначе
		ПредставлениеСпискаВерсий = "";
		Для Каждого ЭлементМассива Из МассивДоступныхВерсий Цикл
			ПредставлениеСпискаВерсий = ПредставлениеСпискаВерсий + "; " + ЭлементМассива.Ключ;
			Элементы.ВерсияФормата.СписокВыбора.Добавить(ЭлементМассива.Ключ);
		КонецЦикла;
		ПредставлениеСпискаВерсий = Сред(ПредставлениеСпискаВерсий, 3);
		СтрокаПоддерживаемыеВерсииФормата = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Поддерживаемые версии формата: %1'"), ПредставлениеСпискаВерсий);
		Объект.ВерсияФормата = Элементы.ВерсияФормата.СписокВыбора[МассивДоступныхВерсий.Количество()-1].Значение;
		ОбновитьПравилаВыгрузкиНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если ВариантОткрытияФормы = "ТолькоЗагрузка" Тогда
		ВидОперации = "Загрузка";
		РежимРазработчика = Ложь;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(ВидОперации) Тогда
		ВидОперации = "Загрузка";
	КонецЕсли;
	// сохраненное по умолчанию значение появляется только при открытии формы.
	Если ЗначениеЗаполнено(Объект.ПутьКМенеджеруОбменаВыгрузки) Тогда
		ОбновитьПравилаВыгрузкиНаСервере();
	КонецЕсли;
	УстановитьВидимость();
#Если ВебКлиент Тогда
	НачатьУстановкуРасширенияРаботыСФайлами();
#КонецЕсли
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ВидОперацииПриИзменении(Элемент)
	УстановитьВидимость();
КонецПроцедуры

&НаКлиенте
Процедура ВерсияФорматаПриИзменении(Элемент)
	Если НЕ ЗначениеЗаполнено(Объект.ВерсияФормата) Тогда
		Возврат;
	КонецЕсли;
	
	ОбновитьПравилаВыгрузкиНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПутьКМенеджеруОбменаВыгрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	НачалоВыбораМодуляМенеджера("ПутьКМенеджеруОбменаВыгрузки", СтандартнаяОбработка, Истина);
КонецПроцедуры

&НаКлиенте
Процедура ПутьКМенеджеруОбменаЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	НачалоВыбораМодуляМенеджера("ПутьКМенеджеруОбменаЗагрузки", СтандартнаяОбработка, Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ПутьКМенеджеруОбменаВыгрузкиПриИзменении(Элемент)
	ПутьКМенеджеруОбменаВыгрузкиПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаПравилВыгрузкиВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ТекущиеДанные = Элементы.ТаблицаПравилВыгрузки.ТекущиеДанные;
	Если ТекущиеДанные.ПолноеИмяМетаданных = "" Тогда
		Возврат;
	КонецЕсли;
	СтруктураОтбор = Новый Структура("ПолноеИмяМетаданных", ТекущиеДанные.ПолноеИмяМетаданных);
	СтрокиДопРегистрации = Объект.ДополнительнаяРегистрация.НайтиСтроки(СтруктураОтбор);
	ТекВыборПериода = Неопределено;
	ТекПериодДанных = Неопределено;
	ТекОтбор = Неопределено;
	
	Если СтрокиДопРегистрации.Количество() > 0 Тогда
		ТекВыборПериода = СтрокиДопРегистрации[0].ВыборПериода;
		ТекПериодДанных = СтрокиДопРегистрации[0].Период;
		ТекОтбор = СтрокиДопРегистрации[0].Отбор;
	КонецЕсли;
	
	ИмяОткрываемойФормы = БазовоеИмяДляФормы + ".Форма.РедактированиеПериодаИОтбора";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Заголовок",           ТекущиеДанные.Представление);
	ПараметрыФормы.Вставить("ВыборПериода",        ТекВыборПериода);
	ПараметрыФормы.Вставить("КомпоновщикНастроек", КомпоновщикНастроекПоИмениТаблицы(
									ТекущиеДанные.ПолноеИмяМетаданных, ТекущиеДанные.Представление, ТекОтбор));
	ПараметрыФормы.Вставить("ПериодДанных",        ТекПериодДанных);
	
	ПараметрыФормы.Вставить("АдресХранилищаФормы", УникальныйИдентификатор);
	
	ОткрытьФорму(ИмяОткрываемойФормы, ПараметрыФормы, Элементы.ТаблицаПравилВыгрузки);
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаПравилВыгрузкиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	
	ПолноеИмяМД = Элементы.ТаблицаПравилВыгрузки.ТекущиеДанные.ПолноеИмяМетаданных;
	ИдентификаторТекущейСтроки = Элементы.ТаблицаПравилВыгрузки.ТекущиеДанные.ПолучитьИдентификатор();
	РедактированиеОтбораСтрокиДополнительныйСоставСервер(ВыбранноеЗначение, ПолноеИмяМД, ИдентификаторТекущейСтроки);
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайлуЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ВыбратьФайлДляЗагрузкиНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ПутьКФайлуВыгрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	ВыбратьФайлДляВыгрузкиНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ИсточникЗагрузкиПриИзменении(Элемент)
	УстановитьВидимость();
КонецПроцедуры

&НаКлиенте
Процедура МестоВыгрузкиПриИзменении(Элемент)
	УстановитьВидимость();
КонецПроцедуры

&НаКлиенте
Процедура ИсточникВыгрузкиПриИзменении(Элемент)
	УстановитьВидимость();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьОперацию(Команда)
	ИдентификаторЗадания = Неопределено;
	
	Если ВидОперации = "Загрузка" Тогда
		Если ИсточникЗагрузки = 1 Тогда // текстовое поле
			Если Не ЗначениеЗаполнено(ДанныеДляЗагрузкиXDTO) Тогда
				ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Текстовое поле с данными для загрузки не заполнено.'"));
				Возврат;
			КонецЕсли;
		Иначе
			Если Не ЗначениеЗаполнено(ПутьКФайлуЗагрузки) Тогда
				ВыбратьФайлДляЗагрузкиНаКлиенте(Истина);
				Возврат;
			КонецЕсли;
		КонецЕсли;
		
		ПодключитьОбработчикОжидания("ЗагрузитьСообщение", 0.1, Истина);
	Иначе
		ПодключитьОбработчикОжидания("ВыгрузитьДанные", 0.1, Истина);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПрерватьВыгрузкуЗагрузку(Команда)
	Если ИдентификаторЗадания = Неопределено Тогда
		Возврат;
	КонецЕсли;
	ПрерватьВыгрузкуЗагрузкуСервер();
	ИдентификаторЗадания = Неопределено;
	Элементы.ВыгрузкаЗагрузка.ТекущаяСтраница = ?(ВидОперации = "Загрузка", Элементы.Загрузка, Элементы.Выгрузка);
	УстановитьВидимостьДоступностьКнопок(Истина);
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = НСтр("ru = 'Выполнение операции прервано.'");
	Сообщение.Сообщить();

КонецПроцедуры


&НаКлиенте
Процедура СохранитьXML(Команда)
	АдресФайлаВХранилище = СохранитьXMLНаСервере();
	Если ЗначениеЗаполнено(ПутьКФайлуВыгрузки) Тогда
		ЗаписатьРезультатВыгрузкиВФайл(АдресФайлаВХранилище);
	Иначе
		ВыбратьФайлДляВыгрузкиНаКлиенте(Истина, АдресФайлаВХранилище);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьXML(Команда)
	АдресФайла = "";
	
	ДопПараметры = Новый Структура("ВидФайла", "ФайлДанных");
	ОписаниеОповещения = Новый ОписаниеОповещения("ПоместитьФайлВХранилищеЗавершить", ЭтотОбъект, ДопПараметры);
	ПомещаемыеФайлы = Новый Массив;
	Интерактивно = Истина;
	Если ЗначениеЗаполнено(ПутьКФайлуЗагрузки) Тогда
		ОписаниеФайла = Новый ОписаниеПередаваемогоФайла(ПутьКФайлуЗагрузки,АдресФайла);
		ПомещаемыеФайлы.Добавить(ОписаниеФайла);
		Интерактивно = Ложь;
	КонецЕсли;
	НачатьПомещениеФайлов(ОписаниеОповещения, ПомещаемыеФайлы,,Интерактивно, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура СохранитьНастройки(Команда)
	АдресФайлаВХранилище = СохранитьНастройкиВыгрузкиНаСервере();
	ПолучитьФайл(АдресФайлаВХранилище, НСтр("ru = 'Файл настроек.xml'"));
КонецПроцедуры

&НаКлиенте
Процедура ВосстановитьНастройки(Команда)
	
	ДопПараметры = Новый Структура("ВидФайла", "ФайлНастроек");
	ОписаниеОповещения = Новый ОписаниеОповещения("ПоместитьФайлВХранилищеЗавершить", ЭтотОбъект, ДопПараметры);
	НачатьПомещениеФайлов(ОписаниеОповещения, , Истина, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьРежимРазработчика(Команда)
	
	РежимРазработчика = Не РежимРазработчика;
	ИсточникЗагрузки = ?(РежимРазработчика, ИсточникЗагрузки, 0);
	МестоВыгрузки = ?(РежимРазработчика, МестоВыгрузки, 0);
	ИсточникВыгрузки = ?(РежимРазработчика, ИсточникВыгрузки, "Отбор");
	УстановитьВидимость();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаКлиенте
Процедура ЗагрузитьСообщение()
	
	Элементы.ДекорацияПоясняющийТекстДлительнойОперации.Заголовок = НСтр("ru = 'Выполняется загрузка данных...'");
	Элементы.ВыгрузкаЗагрузка.ТекущаяСтраница = Элементы.Ожидание;
	
	УстановитьВидимостьДоступностьКнопок(Ложь);
	
	Если ИсточникЗагрузки = 1 Тогда
		ЗапуститьЗагрузкуДанных();
	Иначе
		ЗагрузитьИзФайлаНаКлиенте();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗапуститьЗагрузкуДанных()
	МассивСообщений = Неопределено;
	ДлительнаяОперация = ЗагрузитьДанныеНаСервере();
	ИдентификаторЗадания = ДлительнаяОперация.ИдентификаторЗадания;
	Если ДлительнаяОперация.Статус = "Выполнено" Тогда
		ДлительнаяОперация.Свойство("Сообщения", МассивСообщений);
		СообщитьОбОкончанииОперации(Истина);
	Иначе
		МодульДлительныеОперацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ДлительныеОперацииКлиент");
		ПараметрыОжидания = МодульДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗавершенииОперацииЗагрузки", ЭтотОбъект);
		МодульДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОписаниеОповещения, ПараметрыОжидания);
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриЗавершенииОперацииЗагрузки(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Загрузка данных завершена неудачно.'");
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	КонецЕсли;
	СообщитьОбОкончанииОперации(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьДанные()
	Элементы.ДекорацияПоясняющийТекстДлительнойОперации.Заголовок = НСтр("ru = 'Выполняется выгрузка данных...'");
	Элементы.ВыгрузкаЗагрузка.ТекущаяСтраница = Элементы.Ожидание;
	УстановитьВидимостьДоступностьКнопок(Ложь);
	МассивСообщений = Неопределено;
	ДлительнаяОперация = ВыгрузитьДанныеНаСервере();
	ИдентификаторЗадания = ДлительнаяОперация.ИдентификаторЗадания;
	Если ДлительнаяОперация.Статус = "Выполнено" Тогда
		АдресХраненияРезультата = ДлительнаяОперация.АдресРезультата;
		ДлительнаяОперация.Свойство("Сообщения", МассивСообщений);
		ОбработатьРезультатВыгрузки();
	Иначе
		МодульДлительныеОперацииКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ДлительныеОперацииКлиент");
		ПараметрыОжидания = МодульДлительныеОперацииКлиент.ПараметрыОжидания(ЭтотОбъект);
		ПараметрыОжидания.ВыводитьОкноОжидания = Ложь;
		
		ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗавершенииОперацииВыгрузки", ЭтотОбъект);
		МодульДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОписаниеОповещения, ПараметрыОжидания);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗавершенииОперацииВыгрузки(Результат, ДополнительныеПараметры) Экспорт
	Если Результат = Неопределено Тогда
		ВызватьИсключение НСтр("ru = 'Выгрузка данных завершена неудачно. Отсутствует результат выгрузки.'");
	ИначеЕсли Результат.Статус = "Ошибка" Тогда
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	КонецЕсли;
	АдресХраненияРезультата = Результат.АдресРезультата;
	ОбработатьРезультатВыгрузки();
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьРезультатВыгрузки()
	Если МестоВыгрузки = 1 Тогда
		Объект.РезультатВыгрузкиXDTO = ПолучитьИзВременногоХранилища(АдресХраненияРезультата);
		СообщитьОбОкончанииОперации(Ложь);
	Иначе
		Если НЕ ЗначениеЗаполнено(ПутьКФайлуВыгрузки) Тогда
			// После выбора файла результат выгрузки будет туда записан.
			ВыбратьФайлДляВыгрузкиНаКлиенте(Истина, АдресХраненияРезультата);
		Иначе
			ЗаписатьРезультатВыгрузкиВФайл(АдресХраненияРезультата);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьРезультатВыгрузкиВФайл(АдресХраненияРезультата)
	ОповещениеПолученФайл = Новый ОписаниеОповещения("ПолученФайлВыгрузки", ЭтотОбъект);
	ПолучаемыеФайлы = Новый Массив;
	ФайлВыгрузки = Новый ОписаниеПередаваемогоФайла(ПутьКФайлуВыгрузки, АдресХраненияРезультата);
	ПолучаемыеФайлы.Добавить(ФайлВыгрузки);
	НачатьПолучениеФайлов(ОповещениеПолученФайл,ПолучаемыеФайлы,,Ложь);
КонецПроцедуры

// Параметры:
//   ПолученныеФайлы - Массив из ОписаниеПереданногоФайла, Неопределено - результат получения файлов.
//   ДополнительныеПараметры - Произвольный - произвольные дополнительные параметры.
// 
&НаКлиенте
Процедура ПолученФайлВыгрузки(ПолученныеФайлы, ДополнительныеПараметры) Экспорт
	Если ПолученныеФайлы <> Неопределено Тогда
		Если Не ЗначениеЗаполнено(ПутьКФайлуВыгрузки) Тогда
			ПутьКФайлуВыгрузки = ПолученныеФайлы.Получить(0).Имя;
		КонецЕсли;
		СообщитьОбОкончанииОперации(Ложь);
		ЭтотОбъект.ОбновитьОтображениеДанных();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайлДляЗагрузкиНаКлиенте(ЗагружатьПослеВыбора = Ложь)
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ЗагружатьПослеВыбора", ЗагружатьПослеВыбора);
	
	Оповещение = Новый ОписаниеОповещения("ПодключитьРасширениеРаботыСФайламиЗавершение", ЭтотОбъект, ДополнительныеПараметры);
	НачатьПодключениеРасширенияРаботыСФайлами(Оповещение);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодключитьРасширениеРаботыСФайламиЗавершение(Подключено, ДополнительныеПараметры) Экспорт
	
	Если Не Подключено Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Для продолжения необходимо установить расширение для работы с 1С:Предприятием.'"));
		Возврат;
	КонецЕсли;
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.Фильтр = НСтр("ru = 'Данные загрузки'")+ "(*.xml)|*.xml";
	
	ПараметрыОповещения = Новый Структура;
	ПараметрыОповещения.Вставить("ДляЗагрузки", Истина);
	ПараметрыОповещения.Вставить("ЗагружатьПослеВыбора", ДополнительныеПараметры.ЗагружатьПослеВыбора);
	
	ОповещениеВыбора = Новый ОписаниеОповещения("ВыбранФайл", ЭтотОбъект, ПараметрыОповещения);
	ДиалогОткрытияФайла.Показать(ОповещениеВыбора);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьФайлДляВыгрузкиНаКлиенте(ВыгружатьПослеВыбора = Ложь, АдресХраненияРезультата = "")
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Сохранение);
	ДиалогОткрытияФайла.Фильтр = НСтр("ru = 'Данные выгрузки'")+ "(*.xml)|*.xml";
	ОповещениеВыбора = Новый ОписаниеОповещения("ВыбранФайл", ЭтотОбъект, 
		Новый Структура("ДляЗагрузки, ВыгружатьПослеВыбора, АдресХраненияРезультата", Ложь, ВыгружатьПослеВыбора, АдресХраненияРезультата));
	ДиалогОткрытияФайла.Показать(ОповещениеВыбора);
КонецПроцедуры


&НаКлиенте
Процедура ПоместитьФайлВХранилищеЗавершить(ПомещенныеФайлы, ДополнительныеПараметры) Экспорт
	АдресФайлаЗагрузки = "";
	Если ПомещенныеФайлы <> Неопределено Тогда
		АдресФайлаЗагрузки = ПомещенныеФайлы[0].Хранение;
		Если ДополнительныеПараметры.ВидФайла = "ФайлДанных" Тогда
			ОткрытьXMLНаСервере();
		ИначеЕсли ДополнительныеПараметры.ВидФайла = "ФайлДанныхДляЗагрузки" Тогда
			ЗапуститьЗагрузкуДанных();
		ИначеЕсли ДополнительныеПараметры.ВидФайла = "ФайлНастроек" Тогда
			ЗагрузитьНастройкиВыгрузкиНаСервере();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ВыгрузитьДанныеНаСервере()
	ДополнитьДанныеОтбораПриНеобходимости();
	АдресХраненияРезультата = "";
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("МестоВыгрузки", МестоВыгрузки);
	СтруктураПараметров.Вставить("ЭтоФоновоеЗадание", Истина);
	СтруктураПараметров.Вставить("ПутьКМенеджеруОбменаВыгрузки", ОбработкаОбъект.ПутьКМенеджеруОбменаВыгрузки);
	СтруктураПараметров.Вставить("ВерсияФормата", ОбработкаОбъект.ВерсияФормата);
	СтруктураПараметров.Вставить("УзелОбмена", ОбработкаОбъект.УзелОбмена);
	СтруктураПараметров.Вставить("ПериодОтбораВсехДокументов", ОбработкаОбъект.ПериодОтбораВсехДокументов);
	СтруктураПараметров.Вставить("ДополнительнаяРегистрация", ОбработкаОбъект.ДополнительнаяРегистрация);

	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяОбработки", ИмяОбработки);
	ПараметрыЗадания.Вставить("ИмяМетода", "РезультатВыгрузкиВXML");
	ПараметрыЗадания.Вставить("ПараметрыВыполнения", СтруктураПараметров);
	ПараметрыЗадания.Вставить("ЭтоВнешняяОбработка", Ложь);

	ВыполняемыйМетод = "ДлительныеОперации.ВыполнитьПроцедуруМодуляОбъектаОбработки";

	МодульДлительныеОперации = ОбщегоНазначения.ОбщийМодуль("ДлительныеОперации");
	ПараметрыВыполнения = МодульДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Выгрузка данных EnterpriseData'");
	РезультатФоновогоЗадания = МодульДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗадания, ПараметрыВыполнения);
	Возврат РезультатФоновогоЗадания;
КонецФункции

&НаСервере
Функция ЗагрузитьДанныеНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	СтруктураПараметров = Новый Структура;
	Если ИсточникЗагрузки = 1 Тогда
		СтруктураПараметров.Вставить("ТекстXML", ДанныеДляЗагрузкиXDTO);
	Иначе
		ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаЗагрузки); // ДвоичныеДанные
		АдресНаСервере = ПолучитьИмяВременногоФайла("xml");
		// Удаление временного файла происходит не через УдалитьФайлы(АдресНаСервере) в этой функции,
		// а через УдалитьФайлы(АдресНаСервере) в процедуре ЗагрузкаСообщения модуля обработки.
		ДвоичныеДанные.Записать(АдресНаСервере);
		УдалитьИзВременногоХранилища(АдресФайлаЗагрузки);
		СтруктураПараметров.Вставить("АдресНаСервере", АдресНаСервере);
	КонецЕсли;
	СтруктураПараметров.Вставить("ПутьКМенеджеруОбменаЗагрузки", ОбработкаОбъект.ПутьКМенеджеруОбменаЗагрузки);
	СтруктураПараметров.Вставить("ВерсияФормата", ОбработкаОбъект.ВерсияФормата);
	СтруктураПараметров.Вставить("ЭтоФоновоеЗадание", Истина);
	
	ПараметрыЗадания = Новый Структура;
	ПараметрыЗадания.Вставить("ИмяОбработки", ИмяОбработки);
	ПараметрыЗадания.Вставить("ИмяМетода", "ЗагрузкаСообщения");
	ПараметрыЗадания.Вставить("ПараметрыВыполнения", СтруктураПараметров);
	ПараметрыЗадания.Вставить("ЭтоВнешняяОбработка", Ложь);
	
	ВыполняемыйМетод = "ДлительныеОперации.ВыполнитьПроцедуруМодуляОбъектаОбработки";

	
	МодульДлительныеОперации = ОбщегоНазначения.ОбщийМодуль("ДлительныеОперации");
	ПараметрыВыполнения = МодульДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Загрузка данных EnterpriseData'");
	РезультатФоновогоЗадания = МодульДлительныеОперации.ВыполнитьВФоне(ВыполняемыйМетод, ПараметрыЗадания, ПараметрыВыполнения);
	Возврат РезультатФоновогоЗадания;

КонецФункции

&НаСервере
Процедура ДополнитьДанныеОтбораПриНеобходимости()
	Если Объект.ИсточникВыгрузки = "Узел" Тогда
		СтрокиДерева = Объект.ТаблицаПравилВыгрузки.ПолучитьЭлементы();
		СтрокиДерева.Очистить();
		Объект.ДополнительнаяРегистрация.Очистить();
		Возврат;
	Иначе
		Объект.УзелОбмена = Неопределено;
	КонецЕсли;
	
	Для Каждого СтрГруппыМД Из Объект.ТаблицаПравилВыгрузки.ПолучитьЭлементы() Цикл
		ЭтоДокумент = (СтрГруппыМД.Наименование = "Документы");
		Для Каждого СтрМД Из СтрГруппыМД.ПолучитьЭлементы() Цикл
			ПолноеИмяМД = СтрМД.ПолноеИмяМетаданных;
			СтрокиДополнения = Объект.ДополнительнаяРегистрация.НайтиСтроки(Новый Структура("ПолноеИмяМетаданных", ПолноеИмяМД));
			Если СтрМД.Включить = Ложь Тогда
				Если СтрокиДополнения.Количество() > 0 Тогда
					СтрМД.ПредставлениеОтбора = "";
					ВсегоСтрок = СтрокиДополнения.Количество();
					Для Счетчик = 1 По ВсегоСтрок Цикл
						Объект.ДополнительнаяРегистрация.Удалить(СтрокиДополнения[ВсегоСтрок-Счетчик]);
					КонецЦикла;
				КонецЕсли;
			ИначеЕсли СтрокиДополнения.Количество() = 0 Тогда
				НовСтрока = Объект.ДополнительнаяРегистрация.Добавить();
				ЗаполнитьЗначенияСвойств(НовСтрока, СтрМД, "ПолноеИмяМетаданных, Представление");
				НовСтрока.ОтборСтрокой = НСтр("ru = 'Все объекты'");
				Если ЭтоДокумент Тогда
					НовСтрока.ВыборПериода = Истина;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура НачалоВыбораМодуляМенеджера(РеквизитМодульМенеджера, СтандартнаяОбработка, ОбновлятьВыгрузку)
	СтандартнаяОбработка = Ложь;
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.Фильтр = НСтр("ru = 'Менеджер обмена (*.epf)'") + "|*.epf" ;
	ОповещениеВыбора = Новый ОписаниеОповещения("ВыбранФайл", ЭтотОбъект, 
		Новый Структура("МодульМенеджера, ИмяРеквизита, ОбновлятьВыгрузку", Истина, РеквизитМодульМенеджера, ОбновлятьВыгрузку));
	ДиалогОткрытияФайла.Показать(ОповещениеВыбора);
КонецПроцедуры

&НаСервере
Функция СохранитьXMLНаСервере()
	ТХ = Новый ТекстовыйДокумент;
	ТХ.УстановитьТекст(Объект.РезультатВыгрузкиXDTO);
	АдресНаСервере = ПолучитьИмяВременногоФайла("xml");
	ТХ.Записать(АдресНаСервере);
	АдресВХранилище = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(АдресНаСервере));
	УдалитьФайлы(АдресНаСервере);
	Возврат АдресВХранилище;
КонецФункции

&НаСервере
Процедура ОткрытьXMLНаСервере()
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаЗагрузки); // ДвоичныеДанные
	АдресНаСервере = ПолучитьИмяВременногоФайла("xml");
	ДвоичныеДанные.Записать(АдресНаСервере);
	ТХ = Новый ТекстовыйДокумент;
	ТХ.Прочитать(АдресНаСервере);
	ДанныеДляЗагрузкиXDTO = ТХ.ПолучитьТекст();
	УдалитьФайлы(АдресНаСервере);
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНастройкиВыгрузкиНаСервере()
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресФайлаЗагрузки); // ДвоичныеДанные
	ИмяФайлаНаСервере = ПолучитьИмяВременногоФайла("xml");
	ДвоичныеДанные.Записать(ИмяФайлаНаСервере);

	Объект.ДополнительнаяРегистрация.Очистить();
	Объект.ПериодОтбораВсехДокументов = Новый СтандартныйПериод;
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ИмяФайлаНаСервере);
	НовСтрока = Неопределено;
	Пока ЧтениеXML.Прочитать() Цикл
		Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
			Если ЧтениеXML.Имя = "Period" Тогда
				Пока ЧтениеXML.ПрочитатьАтрибут() Цикл
					Если ЧтениеXML.Имя = "Beg" Тогда
						Объект.ПериодОтбораВсехДокументов.ДатаНачала = XMLЗначение(Тип("Дата"), ЧтениеXML.Значение);
					ИначеЕсли ЧтениеXML.Имя = "End" Тогда
						Объект.ПериодОтбораВсехДокументов.ДатаОкончания = XMLЗначение(Тип("Дата"), ЧтениеXML.Значение);
					КонецЕсли;
				КонецЦикла;
			ИначеЕсли ЧтениеXML.Имя = "Object" Тогда
				НовСтрока = Объект.ДополнительнаяРегистрация.Добавить();
				Пока ЧтениеXML.ПрочитатьАтрибут() Цикл
					Если ЧтениеXML.Имя = "Type" Тогда
						НовСтрока.ПолноеИмяМетаданных = XMLЗначение(Тип("Строка"), ЧтениеXML.Значение);
					ИначеЕсли ЧтениеXML.Имя = "Sel_Period" Тогда
						НовСтрока.ВыборПериода = XMLЗначение(Тип("Булево"), ЧтениеXML.Значение);
					ИначеЕсли ЧтениеXML.Имя = "Beg_Period" Тогда
						НовСтрока.Период.ДатаНачала = XMLЗначение(Тип("Дата"), ЧтениеXML.Значение); 
					ИначеЕсли ЧтениеXML.Имя = "End_Period" Тогда
						НовСтрока.Период.ДатаОкончания = XMLЗначение(Тип("Дата"), ЧтениеXML.Значение);
					ИначеЕсли ЧтениеXML.Имя = "F_String" Тогда
						НовСтрока.ОтборСтрокой = XMLЗначение(Тип("Строка"), ЧтениеXML.Значение);
					КонецЕсли;
				КонецЦикла;
				Продолжить;
			ИначеЕсли ЧтениеXML.Имя = "Filter" Тогда
				ОтборКомпоновки = НовСтрока.Отбор; // ОтборКомпоновкиДанных
				СтрокаОтбора = ОтборКомпоновки.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
				ТипЗначенияОтбора = Неопределено;
				ЗначениеОтбора = Неопределено;
				Пока ЧтениеXML.ПрочитатьАтрибут() Цикл
					Если ЧтениеXML.Имя = "Present" Тогда
						СтрокаОтбора.Представление = XMLЗначение(Тип("Строка"), ЧтениеXML.Значение);
					ИначеЕсли ЧтениеXML.Имя = "Comp" Тогда
						СтрВидСравнения = СокрЛП(XMLЗначение(Тип("Строка"), ЧтениеXML.Значение));
						Если ЗначениеЗаполнено(СтрВидСравнения) Тогда
							СтрокаОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных[СтрВидСравнения];
						КонецЕсли;
					ИначеЕсли ЧтениеXML.Имя = "Val_L" Тогда
						СтрокаОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных(СокрЛП(XMLЗначение(Тип("Строка"), ЧтениеXML.Значение)));
					ИначеЕсли ЧтениеXML.Имя = "Val_R" Тогда
						 ЗначениеОтбора = ЧтениеXML.Значение;
					ИначеЕсли ЧтениеXML.Имя = "Type_R" Тогда
						 ТипЗначенияОтбора = ЧтениеXML.Значение;
					КонецЕсли;
				КонецЦикла;
				Если ЗначениеОтбора <> Неопределено Тогда
					ПолноеИмяЭлементаОтбора = Метаданные.НайтиПоПолномуИмени(ТипЗначенияОтбора);
					Если ПолноеИмяЭлементаОтбора <> Неопределено Тогда
										
						МенеджерОбъектаОтбора = ОбщегоНазначения.МенеджерОбъектаПоПолномуИмени(ТипЗначенияОтбора);
						
						Если СтрНайти(ВРег(ТипЗначенияОтбора), "ПЕРЕЧИСЛЕНИЕ") > 0 Тогда
							СсылкаНаЗначение = МенеджерОбъектаОтбора[ЗначениеОтбора];
						Иначе
							СсылкаНаЗначение = МенеджерОбъектаОтбора.ПолучитьСсылку(Новый УникальныйИдентификатор(ЗначениеОтбора));
						КонецЕсли;
						
						СтрокаОтбора.ПравоеЗначение = СсылкаНаЗначение;
						
					Иначе
						СтрокаОтбора.ПравоеЗначение = XMLЗначение(Тип(ТипЗначенияОтбора),ЗначениеОтбора);
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	ЧтениеXML.Закрыть();
	УдалитьФайлы(ИмяФайлаНаСервере);
	ОбновитьПравилаВыгрузкиНаСервере();
КонецПроцедуры

&НаСервере
Функция СохранитьНастройкиВыгрузкиНаСервере()
	ДополнитьДанныеОтбораПриНеобходимости();
	ИмяВремФайла = ПолучитьИмяВременногоФайла("xml");

	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяВремФайла);
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	ЗаписьXML.ЗаписатьНачалоЭлемента("Objects");
	Если ЗначениеЗаполнено(Объект.ПериодОтбораВсехДокументов) Тогда
		ЗаписьXML.ЗаписатьНачалоЭлемента("Period");
		ЗаписьXML.ЗаписатьАтрибут("Beg", XMLСтрока(Объект.ПериодОтбораВсехДокументов.ДатаНачала));
		ЗаписьXML.ЗаписатьАтрибут("End", XMLСтрока(Объект.ПериодОтбораВсехДокументов.ДатаОкончания));
		ЗаписьXML.ЗаписатьКонецЭлемента(); //Period
	КонецЕсли;
	Для Каждого Стр Из Объект.ДополнительнаяРегистрация Цикл
		ЗаписьXML.ЗаписатьНачалоЭлемента("Object");
		ЗаписьXML.ЗаписатьАтрибут("Type", XMLСтрока(Стр.ПолноеИмяМетаданных));
		Если Стр.ВыборПериода Тогда
			ЗаписьXML.ЗаписатьАтрибут("Sel_Period", XMLСтрока(Стр.ВыборПериода));
			Если ЗначениеЗаполнено(Стр.Период) Тогда
				ЗаписьXML.ЗаписатьАтрибут("Beg_Period", XMLСтрока(Стр.Период.ДатаНачала));
				ЗаписьXML.ЗаписатьАтрибут("End_Period", XMLСтрока(Стр.Период.ДатаОкончания));
			КонецЕсли;
		КонецЕсли;
		ЗаписьXML.ЗаписатьАтрибут("F_String", XMLСтрока(Стр.ОтборСтрокой));
		Если Стр.Отбор.Элементы.Количество() > 0 Тогда
			Для Каждого ЭлементОтбора Из Стр.Отбор.Элементы Цикл
				ЗаписьXML.ЗаписатьНачалоЭлемента("Filter");
				ЗаписьXML.ЗаписатьАтрибут("Comp", XMLСтрока(СокрЛП(ЭлементОтбора.ВидСравнения)));
				ЗаписьXML.ЗаписатьАтрибут("Present", XMLСтрока(СокрЛП(ЭлементОтбора.Представление)));
				Если ЗначениеЗаполнено(ЭлементОтбора.ЛевоеЗначение) Тогда
					ЗаписатьЗначениеОтбора(ЭлементОтбора.ЛевоеЗначение, "_L", ЗаписьXML)
				КонецЕсли;
				Если ЗначениеЗаполнено(ЭлементОтбора.ПравоеЗначение) Тогда
					ЗаписатьЗначениеОтбора(ЭлементОтбора.ПравоеЗначение, "_R", ЗаписьXML)
				КонецЕсли;
				ЗаписьXML.ЗаписатьКонецЭлемента();//Filter
			КонецЦикла;
		КонецЕсли;
		ЗаписьXML.ЗаписатьКонецЭлемента(); //Object
	КонецЦикла;
	ЗаписьXML.ЗаписатьКонецЭлемента(); //Objects
	ЗаписьXML.Закрыть();
	АдресВХранилище = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ИмяВремФайла));
	УдалитьФайлы(ИмяВремФайла);
	Возврат АдресВХранилище;
КонецФункции

&НаСервере
Процедура ЗаписатьЗначениеОтбора(Знач ЭлементОтбора_Значение, Постфикс, ЗаписьXML)
	ТипДанных = ТипЗнч(ЭлементОтбора_Значение);
	ОбъектМетаданных =  Метаданные.НайтиПоТипу(ТипДанных);
	
	Если ОбъектМетаданных <> Неопределено Тогда
		ЗаписьXML.ЗаписатьАтрибут("Type" + Постфикс,  ОбъектМетаданных.ПолноеИмя());
	Иначе 
		ЗаписьXML.ЗаписатьАтрибут("Type" + Постфикс,  Строка(ТипДанных));
	КонецЕсли;
	Если XMLТип(ТипДанных) <> Неопределено Тогда
		ЗаписьXML.ЗаписатьАтрибут("Val" + Постфикс, XMLСтрока(ЭлементОтбора_Значение));
	Иначе
		ЗаписьXML.ЗаписатьАтрибут("Val" + Постфикс, XMLСтрока(Строка(ЭлементОтбора_Значение)));
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимость()
	Элементы.ФормаПрервать.Видимость = Ложь;
	// Вид операции.
	Элементы.ВыгрузкаЗагрузка.ТекущаяСтраница = ?(ВидОперации = "Загрузка", Элементы.Загрузка, Элементы.Выгрузка);
	// Ограниченный вариант использования обработки.
	Если ЗначениеЗаполнено(ВариантОткрытияФормы) Тогда
		Элементы.ФормаВключитьРасширенныеВозможности.Видимость = Ложь;
		Элементы.ВидОперации.Видимость = Ложь;
		Элементы.ПутьКМенеджеруОбменаЗагрузки.Видимость = Ложь;
		Элементы.ГруппаДанныеДляЗагрузки.Видимость = Ложь;
		Элементы.ИсточникЗагрузки.Видимость = Ложь;
		Возврат;
	КонецЕсли;
	Если ВидОперации = "Выгрузка" Тогда
		Элементы.УзелОбмена.Видимость = (РежимРазработчика И Объект.ИсточникВыгрузки = "Узел");
		Элементы.ГруппаНастройкиОтборов.Видимость = (Объект.ИсточникВыгрузки = "Отбор");
		Элементы.ТаблицаПравилВыгрузки.Видимость = (Объект.ИсточникВыгрузки = "Отбор");
		Элементы.ПутьКМенеджеруОбменаВыгрузки.Видимость = РежимРазработчика И Не РазделениеВключено;
		Элементы.ИсточникВыгрузки.Видимость = РежимРазработчика;
		Элементы.МестоВыгрузки.Видимость = РежимРазработчика;
		Элементы.РезультатВыгрузки.Видимость = МестоВыгрузки = 1;
		Элементы.ПутьКФайлуВыгрузки.Видимость = МестоВыгрузки <> 1;
		Элементы.ВыгрузкаОсновное.ОтображениеСтраниц = ?(МестоВыгрузки = 1, ОтображениеСтраницФормы.ЗакладкиСверху, ОтображениеСтраницФормы.Нет);
	Иначе
		Элементы.ПутьКМенеджеруОбменаЗагрузки.Видимость = РежимРазработчика И Не РазделениеВключено;
		Элементы.ИсточникЗагрузки.Видимость = РежимРазработчика;
		Элементы.ГруппаДанныеДляЗагрузки.Видимость = (ИсточникЗагрузки = 1);
		Элементы.ПутьКФайлуЗагрузки.Видимость = (ИсточникЗагрузки <> 1);
	КонецЕсли;
	Элементы.ФормаВключитьРасширенныеВозможности.Пометка = РежимРазработчика;
КонецПроцедуры

&НаСервере
Процедура ОбновитьПравилаВыгрузкиНаСервере()
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	ОбработкаОбъект.ЗаполнениеПравилВыгрузки();
	ЗначениеВРеквизитФормы(ОбработкаОбъект, "Объект");
КонецПроцедуры

&НаСервере
Функция КомпоновщикНастроекПоИмениТаблицы(ИмяТаблицы, Представление, Отбор)
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Возврат ОбработкаОбъект.КомпоновщикНастроекПоИмениТаблицы(ИмяТаблицы, Представление, Отбор, УникальныйИдентификатор);
КонецФункции

&НаСервере
Функция ПредставлениеОтбора(Период, Отбор)
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	Возврат ОбработкаОбъект.ПредставлениеОтбора(Период, Отбор);
КонецФункции

&НаСервере 
Процедура РедактированиеОтбораСтрокиДополнительныйСоставСервер(СтруктураВыбора, ПолноеИмяМД, ИДТекСтроки)
	ДанныеДопРегистрации = Объект.ДополнительнаяРегистрация.НайтиСтроки(
		Новый Структура("ПолноеИмяМетаданных", ПолноеИмяМД));
	ТекущиеДанные = Объект.ТаблицаПравилВыгрузки.НайтиПоИдентификатору(ИДТекСтроки);
	Если ДанныеДопРегистрации.Количество() = 0 Тогда
		Строка = Объект.ДополнительнаяРегистрация.Добавить();
		ЗаполнитьЗначенияСвойств(Строка, ТекущиеДанные,"ПолноеИмяМетаданных, Представление");
		СтрокаЗаполнения = Строка;
	Иначе
		СтрокаЗаполнения = ДанныеДопРегистрации[0];
	КонецЕсли;
	
	СтрокаЗаполнения.Период       = СтруктураВыбора.ПериодДанных;
	СтрокаЗаполнения.Отбор        = СтруктураВыбора.КомпоновщикНастроек.Настройки.Отбор;
	СтрокаЗаполнения.ОтборСтрокой = ПредставлениеОтбора(СтрокаЗаполнения.Период, СтрокаЗаполнения.Отбор);
	
	ТекущиеДанные.ПредставлениеОтбора = СтрокаЗаполнения.ОтборСтрокой;
	ТекущиеДанные.Включить = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаПравилВыгрузкиВключитьПриИзменении(Элемент)
	ДанныеТекущейСтроки = Элементы.ТаблицаПравилВыгрузки.ТекущиеДанные;
	Если ДанныеТекущейСтроки.ПолучитьЭлементы().Количество() > 0 Тогда
		Для Каждого Стр Из ДанныеТекущейСтроки.ПолучитьЭлементы() Цикл
			Стр.Включить = ДанныеТекущейСтроки.Включить;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПутьКМенеджеруОбменаВыгрузкиПриИзмененииНаСервере()
	ОбновитьПравилаВыгрузкиНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВыбранФайл(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	Если ВыбранныеФайлы = Неопределено Тогда
		Возврат;
	КонецЕсли;
	Если ДополнительныеПараметры.Свойство("ДляЗагрузки") Тогда
		Если ДополнительныеПараметры.ДляЗагрузки Тогда
			ПутьКФайлуЗагрузки = ВыбранныеФайлы[0];
			// Проверка существования файла.
			Если ДополнительныеПараметры.ЗагружатьПослеВыбора Тогда
				ПодключитьОбработчикОжидания("ЗагрузитьСообщение", 0.1, Истина);
			КонецЕсли;
		Иначе
			ПутьКФайлуВыгрузки = ВыбранныеФайлы[0];
			Если ДополнительныеПараметры.ВыгружатьПослеВыбора Тогда
				ЗаписатьРезультатВыгрузкиВФайл(ДополнительныеПараметры.АдресХраненияРезультата);
			КонецЕсли;
		КонецЕсли;
	ИначеЕсли ДополнительныеПараметры.Свойство("МодульМенеджера") Тогда
		Объект[ДополнительныеПараметры.ИмяРеквизита] = ВыбранныеФайлы[0];
		Если ДополнительныеПараметры.ОбновлятьВыгрузку Тогда
			ПутьКМенеджеруОбменаВыгрузкиПриИзмененииНаСервере();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьИзФайлаНаКлиенте()
	ДопПараметры = Новый Структура("ВидФайла", "ФайлДанныхДляЗагрузки");
	ОписаниеОповещения = Новый ОписаниеОповещения("ПоместитьФайлВХранилищеЗавершить", ЭтотОбъект, ДопПараметры);
	ПомещаемыеФайлы = Новый Массив;
	Интерактивно = Истина;
	Если ЗначениеЗаполнено(ПутьКФайлуЗагрузки) Тогда
		ОписаниеФайла = Новый ОписаниеПередаваемогоФайла(ПутьКФайлуЗагрузки);
		Интерактивно = Ложь;
		ПомещаемыеФайлы.Добавить(ОписаниеФайла);
	КонецЕсли;
	НачатьПомещениеФайлов(ОписаниеОповещения, ПомещаемыеФайлы, , Интерактивно, УникальныйИдентификатор);
КонецПроцедуры

&НаКлиенте
Процедура СообщитьОбОкончанииОперации(Загрузка = Ложь)
	ВывестиСообщенияФоновогоЗадания();
	ИдентификаторЗадания = Неопределено;
	Элементы.ВыгрузкаЗагрузка.ТекущаяСтраница = ?(Загрузка, Элементы.Загрузка, Элементы.Выгрузка);
	УстановитьВидимостьДоступностьКнопок(Истина);
	Сообщение = Новый СообщениеПользователю();
	Если Загрузка Тогда
		Сообщение.Текст = НСтр("ru = 'Загрузка данных завершена.'");
	Иначе
		Сообщение.Текст = НСтр("ru = 'Выгрузка данных завершена.'");
	КонецЕсли;
	Сообщение.Сообщить();
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВидимостьДоступностьКнопок(ФлагДоступность)
	Элементы.ГруппаВерхняя.Видимость = ФлагДоступность;
	Элементы.ФормаВыполнитьОперацию.Видимость = ФлагДоступность;
	Элементы.ФормаВключитьРасширенныеВозможности.Доступность = ФлагДоступность;
	Элементы.ФормаПрервать.Видимость = НЕ ФлагДоступность;
	ЭтотОбъект.ОбновитьОтображениеДанных();
КонецПроцедуры

&НаКлиенте
Процедура ВывестиСообщенияФоновогоЗадания()
	Если НЕ ЗначениеЗаполнено(МассивСообщений) Тогда
		МассивСообщений = ПрочитатьСообщенияФоновогоЗадания(ИдентификаторЗадания);
	КонецЕсли;
	Если ЗначениеЗаполнено(МассивСообщений) Тогда
		Для Каждого ТекСообщение Из МассивСообщений Цикл
			Если СтрНачинаетсяС(ТекСообщение.Текст,"{") Тогда
				Продолжить;
			КонецЕсли;
			ТекСообщение.Сообщить();
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПрочитатьСообщенияФоновогоЗадания(Идентификатор)
	Если НЕ ЗначениеЗаполнено(Идентификатор) Тогда
		Возврат Неопределено;
	КонецЕсли;
	Задание = ФоновыеЗадания.НайтиПоУникальномуИдентификатору(Идентификатор);
	Если Задание = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат Задание.ПолучитьСообщенияПользователю(Истина);
КонецФункции

&НаСервере
Процедура ПрерватьВыгрузкуЗагрузкуСервер()
	МодульДлительныеОперации = ОбщегоНазначения.ОбщийМодуль("ДлительныеОперации");
	МодульДлительныеОперации.ОтменитьВыполнениеЗадания(ИдентификаторЗадания);
КонецПроцедуры
#КонецОбласти