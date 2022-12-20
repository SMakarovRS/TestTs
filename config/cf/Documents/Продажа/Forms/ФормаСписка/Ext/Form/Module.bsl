﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Параметры.Свойство("КонтекстноеОткрытие", КонтекстноеОткрытие);
	
	Если НЕ КонтекстноеОткрытие Тогда
		РаботаСОтборамиВызовСервера.ВосстановитьНастройкиОтборов(ЭтотОбъект, Список);
	КонецЕсли;
	
	#Область БСП_ПриСозданииНаСервере
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПараметрыРазмещения = ПодключаемыеКоманды.ПараметрыРазмещения();
	ПараметрыРазмещения.КоманднаяПанель = Элементы.ГруппаКоманднаяПанель;
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект, ПараметрыРазмещения);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	#КонецОбласти
	
	// Учет остатков контрагентов.
	МассивЭлементов = Новый Массив;
	МассивЭлементов.Добавить("ОтборОрганизация");
	УправлениеITОтделом8УФ.УстановитьОграничениеТипаДляЭлементовФормы(ЭтаФорма, МассивЭлементов);		
		
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ТипЗнч(ИсточникВыбора) = Тип("УправляемаяФорма") 
		И ИсточникВыбора.ИмяФормы = "ОбщаяФорма.ФормаВыбораОрганизацииКонтрагента"
		И ИсточникВыбора.ВладелецФормы = ЭтаФорма Тогда		
		УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОбработкаВыбораФормы(ЭтаФорма, 
		 				"ОтборОрганизация",
						ОтборОрганизация,
						ВыбранноеЗначение,
						Новый ОписаниеОповещения("ПослеОбработкиВыбора", ЭтотОбъект));
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	
	Если НЕ КонтекстноеОткрытие И НЕ ЗавершениеРаботы Тогда
		
		СохранитьНастройкиОтборов();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Продажа_ФормаСписка_УстановленОтборПериод" Тогда	
		
		Если НЕ КонтекстноеОткрытие Тогда			
			СохранитьНастройкиОтборов();	
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОтборКонтрагентНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ПараметрыФормы 		= Новый Структура;
	ПараметрыФормы.Вставить("ОтборКлиенты",Истина);
	СтандартнаяОбработка= Ложь;
	ОткрытьФорму("Справочник.Контрагенты.Форма.ФормаВыбора", ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура ОтборОрганизацияОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка	= Ложь;
	УстановитьОтборСписка("Организация", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение		= Неопределено;

КонецПроцедуры

&НаКлиенте
Процедура ОтборКонтрагентОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка	= Ложь;
	УстановитьОтборСписка("Контрагент", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение		= Неопределено;

КонецПроцедуры

&НаКлиенте
Процедура ОтборАвторОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка	= Ложь;
	УстановитьОтборСписка("Автор", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение		= Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормы

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
КонецПроцедуры

&НаКлиенте
Процедура СписокВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	// СтандартныеПодсистемы.ОценкаПроизводительности
	КлючеваяОперация = "ДокументПродажа (открытие)";
	ОценкаПроизводительностиКлиент.ЗамерВремени(КлючеваяОперация);
	// Конец СтандартныеПодсистемы.ОценкаПроизводительности
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ПанельОтборов

&НаКлиенте
Процедура ПредставлениеПериодаНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ДопПараметры 		= Новый Структура;	
	ДопПараметры.Вставить("ОписаниеОповещенияОВыбореПериода", 
		"Продажа_ФормаСписка_УстановленОтборПериод"); 

	РаботаСОтборамиКлиент.ПредставлениеПериодаВыбратьПериод(ЭтотОбъект, ДопПараметры);
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьСкрытьПанельОтборов(Команда)	
	
	НовоеЗначениеВидимости = НЕ Элементы.ПанельОтборов.Видимость;
	РаботаСОтборамиКлиент.ПоказатьСкрытьПанельОтборов(ЭтотОбъект, НовоеЗначениеВидимости);
	
КонецПроцедуры

&НаСервере
Процедура СохранитьНастройкиОтборов()
	
	РаботаСОтборамиВызовСервера.СохранитьНастройкиОтборов(ЭтотОбъект);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьОтборСписка(ИмяПоляОтбора, ИмяГруппыРодителя, ЗначениеОтбора)
		
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("ИмяПоляОтбора",				ИмяПоляОтбора);
	ДопПараметры.Вставить("ИмяГруппыРодителя",			ИмяГруппыРодителя);
	ДопПараметры.Вставить("ЗначениеОтбора",				ЗначениеОтбора);
	ДопПараметры.Вставить("ПредставлениеЗначенияОтбора",Строка(ЗначениеОтбора));
	
	РаботаСОтборамиВызовСервера.СоздатьЭлементФормыПоЗначениюОтбора(ЭтотОбъект, ДопПараметры);		
	РаботаСОтборамиВызовСервера.УстановитьОтборСписка(ЭтотОбъект, Список, 
		Новый Структура("ИмяПоляОтбора", ИмяПоляОтбора));
		
	Если НЕ КонтекстноеОткрытие Тогда			
		СохранитьНастройкиОтборов();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОтборОбработкаНавигационнойСсылки(Элемент, 
		НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОтборИД = Сред(Элемент.Имя, СтрДлина("Отбор_") + 1);
	УдалитьЭлементОтбор(ОтборИД);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьЭлементОтбор(ОтборИД)
	
	РаботаСОтборамиВызовСервера.УдалитьОтборСписка(ЭтотОбъект, Список, Новый Структура("ОтборИД", ОтборИД));

	Если НЕ КонтекстноеОткрытие Тогда			
		СохранитьНастройкиОтборов();	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьВсеОтборы(Команда)
			
	УдалитьОтборы();
	
КонецПроцедуры

&НаСервере
Процедура УдалитьОтборы()
		
	РаботаСОтборамиВызовСервера.УдалитьВсеОтборыСписка(ЭтотОбъект, Список);	
	ПредставлениеПериода = РаботаСОтборамиКлиентСервер.ОбновитьПредставлениеПериода(ОтборПериод);
	
	Если НЕ КонтекстноеОткрытие Тогда			
		СохранитьНастройкиОтборов();	
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область БСП

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Элементы.Список);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат) Экспорт
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Элементы.Список, Результат);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Элементы.Список);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

#Область УчетОстатковКонтрагентов

&НаКлиенте
Процедура Подключаемый_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
			
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикНачалоВыбора(ЭтаФорма, ОтборОрганизация, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_Очистка(Элемент, СтандартнаяОбработка)
	
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОчистка(ЭтаФорма, "ОтборОрганизация");
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_АвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, 
	Ожидание, СтандартнаяОбработка)
	
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикАвтоПодбор(ЭтаФорма, 
				"ОтборОрганизация",
				Текст, 
				ДанныеВыбора,
				Ожидание,
				СтандартнаяОбработка);	
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)	
		
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОбработкаВыбора(ЭтаФорма, 
				"ОтборОрганизация", 
				ОтборОрганизация,
				Новый ОписаниеОповещения("ПослеОбработкиВыбора", ЭтотОбъект),
				ВыбранноеЗначение,
				СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеОбработкиВыбора(Результат, ДополнительныеПараметры) Экспорт
	
	Если ЗначениеЗаполнено(ОтборОрганизация) Тогда
		УстановитьОтборСписка("Организация", "ГруппаОтборОрганизация", ОтборОрганизация);
		ОтборОрганизация = ПредопределенноеЗначение("Справочник.Организации.ПустаяСсылка"); 
	КонецЕсли;
	
КонецПроцедуры	

#КонецОбласти

#КонецОбласти

