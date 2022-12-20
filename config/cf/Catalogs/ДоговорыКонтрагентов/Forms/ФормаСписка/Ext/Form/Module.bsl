﻿
#Область ОбработчикиСобытийФормы

&НаСервере
// Процедура - обработчик события ПриСозданииНаСервере.
//
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Список.Параметры.УстановитьЗначениеПараметра("ДатаАктуальности", НачалоДня(ТекущаяДатаСеанса()));

	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	Если Параметры.Отбор.Свойство("Владелец", КонтрагентВладелец) Тогда		
		КонтекстноеОткрытие = Истина;
	КонецЕсли;
	
	Если КонтекстноеОткрытие Тогда
		
		СписокДоговоровПоУмолчанию = ПолучитьДоговорыПоУмолчанию();	
		Если СписокДоговоровПоУмолчанию.Количество() > 0 Тогда		
			УстановитьОформлениеДоговоровПоУмолчанию(СписокДоговоровПоУмолчанию);		
		КонецЕсли;
		Элементы.ФормаУстановитьКакДоговорПоУмолчанию.Видимость = Истина;
		ПредставлениеПериода	= РаботаСОтборамиКлиентСервер.ОбновитьПредставлениеПериода(
			Новый СтандартныйПериод);

	Иначе
		
		Элементы.ФормаУстановитьКакДоговорПоУмолчанию.Видимость = Ложь;
		ДопПараметры 				= Новый Структура;
		СтруктураИменПолейОтборов	= Новый Структура;
		СтруктураИменПолейОтборов.Вставить("ОтборПериод", "ДатаДоговора"); 
		ДопПараметры.Вставить("СтруктураИменПолейОтборов", СтруктураИменПолейОтборов);
		РаботаСОтборамиВызовСервера.ВосстановитьНастройкиОтборов(ЭтотОбъект, Список, ДопПараметры);
		
	КонецЕсли;
	
	// Учет остатков контрагентов.
	МассивЭлементов = Новый Массив;
	МассивЭлементов.Добавить("ОтборОрганизация");
	УправлениеITОтделом8УФ.УстановитьОграничениеТипаДляЭлементовФормы(ЭтаФорма, МассивЭлементов);

КонецПроцедуры // ПриСозданииНаСервере()

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	//@skip-warning
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
	
	Если Не КонтекстноеОткрытие И НЕ ЗавершениеРаботы Тогда
		
		СохранитьНастройкиОтборов();
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ДоговорыКонтрагентов_ФормаСписка_УстановленОтборПериод" Тогда	
		
		Если НЕ КонтекстноеОткрытие Тогда			
			СохранитьНастройкиОтборов();	
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура СписокПриАктивизацииСтроки(Элемент)
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

КонецПроцедуры

&НаКлиенте
Процедура ПредставлениеПериодаНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка	= Ложь;
	ДопПараметры 			= Новый Структура;
	ДопПараметры.Вставить("ИмяПоляОтбора", "ДатаДоговора");	
	ДопПараметры.Вставить("ОписаниеОповещенияОВыбореПериода", 
		"ДоговорыКонтрагентов_ФормаСписка_УстановленОтборПериод"); 

	РаботаСОтборамиКлиент.ПредставлениеПериодаВыбратьПериод(ЭтотОбъект, ДопПараметры);

КонецПроцедуры

&НаКлиенте
Процедура ОтборКонтрагентОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка	= Ложь;
	УстановитьОтборСписка("Владелец", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение		= Неопределено;
	
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
Процедура ОтборСтатусОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если Не ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	СтандартнаяОбработка	= Ложь;
	УстановитьОтборСписка("Статус", Элемент.Родитель.Имя, ВыбранноеЗначение);
	ВыбранноеЗначение		= Неопределено;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура УстановитьКакДоговорПоУмолчанию(Команда)
	СписокДоговоровПоУмолчанию = Новый СписокЗначений;
	
	ТекущаяСтрокаСписка = Элементы.Список.ТекущиеДанные;
	
	Если ТекущаяСтрокаСписка = Неопределено Тогда
		
		ТекстСообщения = НСтр("ru = 'Не выбран договор, который необходимо установить как Договор по умолчанию'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстСообщения);
		
		Возврат;
		
	КонецЕсли;
	
	НовыйДоговорПоУмолчанию	= ТекущаяСтрокаСписка.Ссылка;
	Контрагент				= ТекущаяСтрокаСписка.Владелец;
	
	Для каждого ЭлементУсловногоОформления Из Список.УсловноеОформление.Элементы Цикл
		Если ЭлементУсловногоОформления.ИдентификаторПользовательскойНастройки = "Предустановленный"
			И ЭлементУсловногоОформления.Представление = НСтр("ru = 'Договоры по умолчанию'") Тогда
			
			ЭлементОтбора				= ЭлементУсловногоОформления.Отбор.Элементы[0];
			СписокДоговоровПоУмолчанию	= ЭлементОтбора.ПравоеЗначение;
			
		КонецЕсли;
	КонецЦикла;
	
	Если НЕ СписокДоговоровПоУмолчанию.НайтиПоЗначению(НовыйДоговорПоУмолчанию) = Неопределено Тогда
		
		Возврат;
		
	КонецЕсли;
	
	ИзменитьКарточкуКонтрагентаИПоменятьОформлениеСписка(Контрагент, НовыйДоговорПоУмолчанию, 
		СписокДоговоровПоУмолчанию);
	
	Оповестить("ПеречитатьДоговорПоУмолчанию");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусДействует(Команда)
	
	ВыделенныеСтроки = ПолучитьВыделенныеВСпискеСсылки();
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = НСтр("ru='У выделенных в списке договоров будет установлен статус ""Действует"". Продолжить?'");	
	
	ПоказатьВопрос(Новый ОписаниеОповещения("УстановитьСтатусДействуетЗавершение", ЭтотОбъект, 
					Новый Структура("ВыделенныеСтроки", ВыделенныеСтроки)), ТекстВопроса, РежимДиалогаВопрос.ДаНет);

КонецПроцедуры
				
&НаКлиенте
Процедура УстановитьСтатусДействуетЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
       
    Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;
	
	ВыделенныеСтроки = ДополнительныеПараметры.ВыделенныеСтроки;        
    ОчиститьСообщения();
    УстановитьСтатусСервер(ВыделенныеСтроки, "Действует");   
	Элементы.Список.Обновить();
	
КонецПроцедуры				

&НаКлиенте
Процедура УстановитьСтатусЗакрыт(Команда)
	
	ВыделенныеСтроки = ПолучитьВыделенныеВСпискеСсылки();
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = НСтр("ru='У выделенных в списке договоров будет установлен статус ""Закрыт"". Продолжить?'");	
	ПоказатьВопрос(Новый ОписаниеОповещения("УстановитьСтатусЗакрытЗавершение", ЭтотОбъект, 
					Новый Структура("ВыделенныеСтроки", ВыделенныеСтроки)), ТекстВопроса, РежимДиалогаВопрос.ДаНет);

КонецПроцедуры
				
&НаКлиенте
Процедура УстановитьСтатусЗакрытЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
       
    Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;
	
	ВыделенныеСтроки = ДополнительныеПараметры.ВыделенныеСтроки;        
    ОчиститьСообщения();
    УстановитьСтатусСервер(ВыделенныеСтроки, "Закрыт");   
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусНеСогласован(Команда)
	
	ВыделенныеСтроки = ПолучитьВыделенныеВСпискеСсылки();
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = НСтр("ru='У выделенных в списке договоров будет установлен статус ""Не согласован"". Продолжить?'");	
	ПоказатьВопрос(Новый ОписаниеОповещения("УстановитьСтатусНеСогласованЗавершение", ЭтотОбъект, 
					Новый Структура("ВыделенныеСтроки", ВыделенныеСтроки)), ТекстВопроса, РежимДиалогаВопрос.ДаНет);

КонецПроцедуры
				
&НаКлиенте
Процедура УстановитьСтатусНеСогласованЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
       
    Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;
	
	ВыделенныеСтроки = ДополнительныеПараметры.ВыделенныеСтроки;        
    ОчиститьСообщения();
    УстановитьСтатусСервер(ВыделенныеСтроки, "НеСогласован");   
	Элементы.Список.Обновить();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусСогласование(Команда)
	
	ВыделенныеСтроки = ПолучитьВыделенныеВСпискеСсылки();
	Если ВыделенныеСтроки.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТекстВопроса = НСтр("ru='У выделенных в списке договоров будет установлен статус ""Согласование"". Продолжить?'");		
	ПоказатьВопрос(Новый ОписаниеОповещения("УстановитьСтатусСогласованиеЗавершение", ЭтотОбъект, 
					Новый Структура("ВыделенныеСтроки", ВыделенныеСтроки)), ТекстВопроса, РежимДиалогаВопрос.ДаНет);

КонецПроцедуры

&НаКлиенте
Процедура УстановитьСтатусСогласованиеЗавершение(РезультатВопроса, ДополнительныеПараметры) Экспорт
       
    Если РезультатВопроса <> КодВозвратаДиалога.Да Тогда
        Возврат;
    КонецЕсли;
	
	ВыделенныеСтроки = ДополнительныеПараметры.ВыделенныеСтроки;        
    ОчиститьСообщения();
    УстановитьСтатусСервер(ВыделенныеСтроки, "Согласование");   
	Элементы.Список.Обновить();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
// Функция получает и возвращает выборку договоров по умолчанию .
// 
// МассивКонтрагент - массив контрагентов для которых необходимо выбрать договоры по умолчанию.
//
Функция ПолучитьДоговорыПоУмолчанию(МассивКонтрагент = Неопределено)
	
	Запрос			= Новый Запрос;
	
	Запрос.Текст	=
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	Контрагенты.ДоговорПоУмолчанию КАК Договор
	|ИЗ
	|	Справочник.Контрагенты КАК Контрагенты
	|ГДЕ
	|	НЕ Контрагенты.ЭтоГруппа
	|	И НЕ Контрагенты.ДоговорПоУмолчанию = ЗНАЧЕНИЕ(Справочник.ДоговорыКонтрагентов.ПустаяССылка)
	|	И &УсловиеОтбораПоКонтрагентам";
	
	
	Запрос.Текст = СтрЗаменить(Запрос.Текст, 
		"&УсловиеОтбораПоКонтрагентам",
		?(ТипЗнч(МассивКонтрагент) = Тип("Массив"), "Контрагенты.Ссылка В (&МассивКонтрагент)", "Истина"));
	
	РезультатЗапроса			= Запрос.Выполнить().Выгрузить();
	
	СписокДоговоровПоУмолчанию	= Новый СписокЗначений;
	СписокДоговоровПоУмолчанию.ЗагрузитьЗначения(РезультатЗапроса.ВыгрузитьКолонку("Договор"));
	
	Возврат СписокДоговоровПоУмолчанию;
	
КонецФункции //ПолучитьДоговорыПоУмолчанию()

&НаСервере
// Процедура выделяет в списке договоры по умолчанию
//
Процедура УстановитьОформлениеДоговоровПоУмолчанию(СписокДоговоровПоУмолчанию)
	
	Для каждого ЭлементУсловногоОформления Из Список.УсловноеОформление.Элементы Цикл
		Если ЭлементУсловногоОформления.ИдентификаторПользовательскойНастройки = "Предустановленный" Тогда
			Список.УсловноеОформление.Элементы.Удалить(ЭлементУсловногоОформления);
		КонецЕсли;
	КонецЦикла;
	
	ЭлементыУсловногоОформленияСписка	= Список.УсловноеОформление.Элементы;
	ЭлементУсловногоОформления			= ЭлементыУсловногоОформленияСписка.Добавить();
	
	ЭлементОтбора 						= ЭлементУсловногоОформления.Отбор.Элементы.Добавить(
		Тип("ЭлементОтбораКомпоновкиДанных"));
	
	ЭлементОтбора.ЛевоеЗначение 		= Новый ПолеКомпоновкиДанных("Ссылка");
	ЭлементОтбора.ВидСравнения 			= ВидСравненияКомпоновкиДанных.ВСписке;
	ЭлементОтбора.ПравоеЗначение 		= СписокДоговоровПоУмолчанию;
	
	ЭлементУсловногоОформления.Оформление.УстановитьЗначениеПараметра("Шрифт", Новый Шрифт(,,Истина,));
	
	ЭлементУсловногоОформления.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.Недоступный;
	ЭлементУсловногоОформления.ИдентификаторПользовательскойНастройки = "Предустановленный";
	ЭлементУсловногоОформления.Представление = НСтр("ru = 'Договоры по умолчанию'");
	
КонецПроцедуры //УстановитьОформлениеДоговоровПоУмолчанию()

&НаСервере
// Процедура - записывает в карточку контрагента новое значение.
// и обновляет визуальное представление договора по умолчанию в форме списке.
//
Процедура ИзменитьКарточкуКонтрагентаИПоменятьОформлениеСписка(Контрагент, НовыйДоговорПоУмолчанию, 
	СписокДоговоровПоУмолчанию)
	
	КонтрагентОбъект 						= Контрагент.ПолучитьОбъект();
	СтарыйДоговорПоУмолчанию				= КонтрагентОбъект.ДоговорПоУмолчанию;
	КонтрагентОбъект.ДоговорПоУмолчанию		= НовыйДоговорПоУмолчанию;
	
	Попытка
		
		КонтрагентОбъект.Записать();
		
	Исключение
		
		ТекстСообщения = НСтр("ru = 'Не удалось поменять договор по умолчанию в карточке контрагента.'");
		ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
		
	КонецПопытки;
	
	ЭлементСпискаЗначений 					= СписокДоговоровПоУмолчанию.НайтиПоЗначению(СтарыйДоговорПоУмолчанию);
	
	Если НЕ ЭлементСпискаЗначений = Неопределено Тогда
		
		СписокДоговоровПоУмолчанию.Удалить(ЭлементСпискаЗначений);
		
	КонецЕсли;
	
	СписокДоговоровПоУмолчанию.Добавить(НовыйДоговорПоУмолчанию);
	
	УстановитьОформлениеДоговоровПоУмолчанию(СписокДоговоровПоУмолчанию);
	
КонецПроцедуры //ИзменитьКарточкуКонтрагентаИПоменятьОформлениеСписка()

// СтандартныеПодсистемы.ПодключаемыеКоманды
//@skip-warning
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Элементы.Список);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат) Экспорт
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Элементы.Список, Результат);
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Элементы.Список);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

&НаКлиенте
Функция ПолучитьВыделенныеВСпискеСсылки()	
	
	МассивСсылок = Новый Массив;
	СписокСтрок = Элементы.Список;
	Для Итератор = 0 По СписокСтрок.ВыделенныеСтроки.Количество() - 1 Цикл
		Если ТипЗнч(СписокСтрок.ВыделенныеСтроки[Итератор]) <> Тип("СтрокаГруппировкиДинамическогоСписка") Тогда
			МассивСсылок.Добавить(СписокСтрок.ВыделенныеСтроки[Итератор]);
		КонецЕсли;
	КонецЦикла;
	
	Если МассивСсылок.Количество() = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru='Команда не может быть выполнена для указанного объекта.'"));
	КонецЕсли;
	
	Возврат МассивСсылок;
	
КонецФункции

&НаСервереБезКонтекста
Функция УстановитьСтатусСервер(Знач Договоры, НовыйСтатус)
	
	Возврат Справочники.ДоговорыКонтрагентов.УстановитьСтатус(Договоры, 
		Перечисления.СтатусыДоговоровКонтрагентов[НовыйСтатус]);
	
КонецФункции

#Область УчетОстатковКонтрагентов

//@skip-warning
&НаКлиенте
Процедура Подключаемый_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
			
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикНачалоВыбора(ЭтаФорма, ОтборОрганизация, СтандартнаяОбработка);
	
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_Очистка(Элемент, СтандартнаяОбработка)
	
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОчистка(ЭтаФорма, "ОтборОрганизация");
	
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_АвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, 
	СтандартнаяОбработка)
	
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикАвтоПодбор(ЭтаФорма, 
				"ОтборОрганизация",
				Текст, 
				ДанныеВыбора,
				Ожидание,
				СтандартнаяОбработка);	
	
КонецПроцедуры

//@skip-warning
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

#Область ПанельОтборов

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
		
	Если Не КонтекстноеОткрытие Тогда
		
		СохранитьНастройкиОтборов();
		
	КонецЕсли;	
	
КонецПроцедуры

//@skip-warning
&НаКлиенте
Процедура Подключаемый_ОтборОбработкаНавигационнойСсылки(Элемент, НавигационнаяСсылкаФорматированнойСтроки, 
	СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ОтборИД = Сред(Элемент.Имя, СтрДлина("Отбор_") + 1);
	УдалитьЭлементОтбор(ОтборИД);
	
КонецПроцедуры

&НаСервере
Процедура УдалитьЭлементОтбор(ОтборИД)
	
	РаботаСОтборамиВызовСервера.УдалитьОтборСписка(ЭтотОбъект, Список, Новый Структура("ОтборИД", ОтборИД));
	
	Если Не КонтекстноеОткрытие Тогда
		
		СохранитьНастройкиОтборов();
		
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьВсеОтборы(Команда)
			
	УдалитьОтборы();
	
КонецПроцедуры

&НаСервере
Процедура УдалитьОтборы()
	
	МассивПолей = Новый Массив;
	МассивПолей.Добавить("ДатаДоговора");
	ДопПараметры = Новый Структура;
	ДопПараметры.Вставить("МассивПолейОтборов", МассивПолей);
	РаботаСОтборамиВызовСервера.УдалитьВсеОтборыСписка(ЭтотОбъект, Список, ДопПараметры);	
	ПредставлениеПериода = РаботаСОтборамиКлиентСервер.ОбновитьПредставлениеПериода(ОтборПериод);
	
	Если Не КонтекстноеОткрытие Тогда
		
		СохранитьНастройкиОтборов();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти
