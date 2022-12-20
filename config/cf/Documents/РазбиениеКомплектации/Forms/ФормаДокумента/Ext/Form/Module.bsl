﻿
#Область ОписаниеПеременных

// СтандартныеПодсистемы.ОценкаПроизводительности
&НаКлиенте
Перем ИдентификаторЗамераПроведение;
// Конец СтандартныеПодсистемы.ОценкаПроизводительности

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	СЛС.ПриСозданииНаСервере(Объект, Отказ, СтандартнаяОбработка, Параметры, ЭтаФорма);
		
	// Установка реквизитов формы.
	ДатаДокумента = Объект.Дата;
	Если НЕ ЗначениеЗаполнено(ДатаДокумента) Тогда
		ДатаДокумента = ТекущаяДатаСеанса();
		Если НЕ ЗначениеЗаполнено(Объект.ТипРазукомплектации) Тогда
			Объект.ТипРазукомплектации = Перечисления.ТипыРазукомплектации.РазбитьКомплект;
		КонецЕсли;		
	КонецЕсли;
	
	Если Параметры.Свойство("МестоХранения") Тогда
		Объект.МестоХранения = Параметры.МестоХранения;
	КонецЕсли;
	Если Параметры.Свойство("Организация") Тогда
		Если ЗначениеЗаполнено(Параметры.Организация) Тогда
			Объект.Организация = Параметры.Организация;
		КонецЕсли;		
	КонецЕсли;
	
	Если Параметры.Свойство("ТипРазукомплектации") И Параметры.Свойство("КарточкаНоменклатурыКомплекта") Тогда
		Если ЗначениеЗаполнено(Параметры.ТипРазукомплектации) Тогда
			Объект.ТипРазукомплектации = Параметры.ТипРазукомплектации;
		КонецЕсли;		
		Если ЗначениеЗаполнено(Параметры.КарточкаНоменклатурыКомплекта) Тогда
			Объект.КарточкаНоменклатурыКомплекта = Параметры.КарточкаНоменклатурыКомплекта;
		КонецЕсли;		
		ОбновитьКомплектациюНаСервере();
	КонецЕсли;	
	
	Если Объект.Ссылка.Пустая() Тогда
		// Документ создается из обработки "РабочийСтол".
		Если Параметры.Свойство("РабочийСтолЗначенияЗаполнения") Тогда
			ЗаполнитьЗначенияСвойств(Объект, Параметры.РабочийСтолЗначенияЗаполнения);
		КонецЕсли;

	КонецЕсли; 
		
	#Область БСП_ПриСозданииНаСервере
	
	// СтандартныеПодсистемы.Свойства
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ИмяЭлементаДляРазмещения", "СтраницаДополнительныеРеквизиты");
	УправлениеСвойствами.ПриСозданииНаСервере(ЭтотОбъект, ДополнительныеПараметры);
	// Конец СтандартныеПодсистемы.Свойства
	
	// СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов
	ЗапретРедактированияРеквизитовОбъектов.ЗаблокироватьРеквизиты(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ЗапретРедактированияРеквизитовОбъектов
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
	ПодключаемыеКоманды.ПриСозданииНаСервере(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.ПодключаемыеКоманды	

	// ВерсионированиеОбъектов
	ВерсионированиеОбъектов.ПриСозданииНаСервере(ЭтаФорма);
	// Конец ВерсионированиеОбъектов
		
	#КонецОбласти
	
	ТекущийЭлемент = Элементы.ДеревоНоменклатуры;
	
	// Вывод дерева	
	ВывестиДеревоНоменклатуры();
	
	Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка = УправлениеITОтделом8УФ.ОтображатьИнвентарныеСерийныеНомера();		
	Если Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка = Истина Тогда
		ОбновитьИнвентарныеИСерийныеНомераНаСервере();
	КонецЕсли;	
	
	// Учет остатков контрагентов.
	МассивЭлементов = Новый Массив;
	МассивЭлементов.Добавить("Организация");
	УправлениеITОтделом8УФ.УстановитьОграничениеТипаДляЭлементовФормы(ЭтаФорма, МассивЭлементов); 
	
	УстановитьВидимостьДоступность();	
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиент.НачатьОбновлениеКоманд(ЭтотОбъект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды
	
	// Корректировки документа
	УправлениеITОтделом8УФКлиент.ОбновитьНадписьАвтор(Объект, ЭтаФорма);
	
	// Разворачиваем дерево
	КоллекцияЭлементовДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки = Строка.ПолучитьИдентификатор();
		Элементы.ДеревоНоменклатуры.Развернуть(ИдентификаторСтроки, Истина);
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	// СтандартныеПодсистемы.ОценкаПроизводительности
	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
       ИдентификаторЗамераПроведение = ОценкаПроизводительностиКлиент.ЗамерВремени();
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ОценкаПроизводительности
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	// Корректировки документа
	УправлениеITОтделом8УФКлиент.ОбновитьНадписьАвтор(Объект, ЭтаФорма);
	
	// СтандартныеПодсистемы.ОценкаПроизводительности
	Если ПараметрыЗаписи.РежимЗаписи = РежимЗаписиДокумента.Проведение Тогда
        ОценкаПроизводительностиКлиент.УстановитьКлючевуюОперациюЗамера(ИдентификаторЗамераПроведение, 
			"ДокументРазбиениеКомплектации (проведение)");	
	КонецЕсли;
	// Конец СтандартныеПодсистемы.ОценкаПроизводительности

КонецПроцедуры

// Процедура - обработчик события ПриЧтенииНаСервере.
//
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	СЛС.ПриЧтенииНаСервере(ТекущийОбъект, ЭтаФорма);
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
	// СтандартныеПодсистемы.ДатыЗапретаИзменения
	ДатыЗапретаИзменения.ОбъектПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.ДатыЗапретаИзменения
	
	// СтандартныеПодсистемы.ПодключаемыеКоманды
    ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
    // Конец СтандартныеПодсистемы.ПодключаемыеКоманды	
	
	// СтандартныеПодсистемы.УправлениеДоступом
    УправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
    // Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры // ПриЧтенииНаСервере()

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)

	// СтандартныеПодсистемы.Свойства
	Если УправлениеСвойствамиКлиент.ОбрабатыватьОповещения(ЭтотОбъект, ИмяСобытия, Параметр) Тогда
		ОбновитьЭлементыДополнительныхРеквизитов();
		УправлениеСвойствамиКлиент.ПослеЗагрузкиДополнительныхРеквизитов(ЭтотОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если ТекущийОбъект.ДатаСоздания = Дата(1, 1, 1) Тогда
		ТекущийОбъект.ДатаСоздания = ТекущаяДатаСеанса();
	Иначе
		ТекущийОбъект.ДатаКорректировки = ТекущаяДатаСеанса();
	КонецЕсли; 
	
	Если ТекущийОбъект.Автор = Справочники.Пользователи.ПустаяСсылка() Тогда
		ТекущийОбъект.Автор = Пользователи.ТекущийПользователь();
	Иначе
		ТекущийОбъект.АвторКорректировки = Пользователи.ТекущийПользователь();
	КонецЕсли; 
	
	СохранитьДеревоНоменклатуры(ТекущийОбъект);
	
	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ПередЗаписьюНаСервере(ЭтотОбъект, ТекущийОбъект);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	// СтандартныеПодсистемы.УправлениеДоступом
	УправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	// Конец СтандартныеПодсистемы.УправлениеДоступом
	
	СЛС.ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи, ЭтаФорма);
	
	// Обработчик подсистемы запрета редактирования реквизитов объектов
	ЗапретРедактированияРеквизитовОбъектов.ЗаблокироватьРеквизиты(ЭтаФорма);
	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)

	// СтандартныеПодсистемы.Свойства
	УправлениеСвойствами.ОбработкаПроверкиЗаполнения(ЭтотОбъект, Отказ, ПроверяемыеРеквизиты);
	// Конец СтандартныеПодсистемы.Свойства
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаВыбора(ВыбранноеЗначение, ИсточникВыбора)
	
	Если ТипЗнч(ИсточникВыбора) = Тип("УправляемаяФорма") 
		И ИсточникВыбора.ИмяФормы = "ОбщаяФорма.ФормаВыбораОрганизацииКонтрагента"
		И ИсточникВыбора.ВладелецФормы = ЭтаФорма Тогда
		УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОбработкаВыбораФормы(ЭтаФорма, 
		 				"Организация",
						Объект.Организация,
						ВыбранноеЗначение,
						Новый ОписаниеОповещения("ПослеОбработкиВыбора", ЭтотОбъект));	
	КонецЕсли;	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
// Процедура - обработчик события ПриИзменении поля ввода Дата.
// В процедуре определяется ситуация, когда при изменении своей даты документ 
// оказывается в другом периоде нумерации документов, и в этом случае
// присваивает документу новый уникальный номер.
// Переопределяет соответствующий параметр формы.
//
Процедура ДатаПриИзменении(Элемент)
	
	// Обработка события изменения даты.
	ДатаПередИзменением = ДатаДокумента;
	ДатаДокумента = Объект.Дата;
	Если Объект.Дата <> ДатаПередИзменением Тогда
		СтруктураДанные = ПолучитьДанныеДатаПриИзменении(Объект.Ссылка, Объект.Дата, ДатаПередИзменением);
		Если СтруктураДанные.РазностьДат <> 0 Тогда
			Объект.Номер = "";
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры // ДатаПриИзменении()

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	Объект.Номер = "";
КонецПроцедуры

&НаКлиенте
Процедура КарточкаНоменклатурыКомплектаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;	
	
	Если НЕ ЗначениеЗаполнено(Объект.ТипРазукомплектации) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(
			НСтр("ru = 'Выберите тип разукомплектации.'"), ,
			"Объект.ТипРазукомплектации");
		Возврат;		
	КонецЕсли;

	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ОтборТолькоНеИспользованные", Ложь);
	ПараметрыФормы.Вставить("ВидимостьОтборПоступление", Ложь);
	ПараметрыФормы.Вставить("ВыбранноеЗначение", Объект.КарточкаНоменклатурыКомплекта);
	ПараметрыФормы.Вставить("ОтборТолькоКомплекты", Истина);
	Если Объект.Ссылка.Пустая() Тогда
		ПараметрыФормы.Вставить("ДатаАктуальности", КонецДня(ТекущаяДатаНаСервере()));
	Иначе
		ПараметрыФормы.Вставить("ДатаАктуальности", Объект.Дата);
	КонецЕсли;	
	ПараметрыФормы.Вставить("Организация", Объект.Организация);
	ПараметрыФормы.Вставить("МестоХранения", Объект.МестоХранения);
	
	ОткрытьФорму("Справочник.КарточкиНоменклатуры.ФормаВыбора", ПараметрыФормы, Элемент);	
КонецПроцедуры

&НаКлиенте
Процедура КарточкаНоменклатурыКомплектаПриИзменении(Элемент)
	
	ОбновитьКомплектациюНаСервере();
	УстановитьВидимостьДоступность();
	КоллекцияЭлементовДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	Для Каждого Строки Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки = Строки.ПолучитьИдентификатор();
		Элементы.ДеревоНоменклатуры.Развернуть(ИдентификаторСтроки, Истина);		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормы

&НаКлиенте
Процедура ДеревоНоменклатурыПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПередУдалением(Элемент, Отказ)
	Отказ = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоНоменклатурыПриИзменении(Элемент)
	
	ОбновитьНумерациюВДеревеЗначенийНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура НадписьАвторНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Спк = УправлениеITОтделом8УФКлиент.ПолучитьСписокНадписьАвтор(Объект);	
	ПоказатьВыборИзСписка(Новый ОписаниеОповещения("НадписьАвторНажатиеЗавершение", ЭтотОбъект), Спк, Элементы.НадписьАвтор, );
КонецПроцедуры

&НаКлиенте
Процедура НадписьАвторНажатиеЗавершение(ВыбранныйЭлемент, ДополнительныеПараметры) Экспорт    

КонецПроцедуры

&НаКлиенте
Процедура ОтображатьИнвентарныеИСерийныеНомера(Команда)
	Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка = НЕ Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка;
	УправлениеITОтделом8УФ.СохранитьНастройкуОтображатьИнвентарныеСерийныеНомера(Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка);
	УстановитьВидимостьДоступность();
	КоллекцияЭлементовДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	Для Каждого Строки Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки = Строки.ПолучитьИдентификатор();
		Элементы.ДеревоНоменклатуры.Развернуть(ИдентификаторСтроки, Истина);		
	КонецЦикла;	
КонецПроцедуры

&НаСервере
Процедура УстановитьФлагиНаСервере(Флаг)
	СохранитьДеревоНоменклатуры();
	Для каждого Строки Из Объект.Номенклатура Цикл
		Строки.Разбиение = Флаг;
	КонецЦикла;
	ВывестиДеревоНоменклатуры();
КонецПроцедуры

&НаКлиенте
Процедура ВыделитьВсе(Команда)
	УстановитьФлагиНаСервере(Истина);
	КоллекцияЭлементовДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	Для Каждого Строки Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки = Строки.ПолучитьИдентификатор();
		Элементы.ДеревоНоменклатуры.Развернуть(ИдентификаторСтроки, Истина);		
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсе(Команда)
	УстановитьФлагиНаСервере(Ложь);
	КоллекцияЭлементовДерева = ДеревоНоменклатуры.ПолучитьЭлементы();
	Для Каждого Строки Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки = Строки.ПолучитьИдентификатор();
		Элементы.ДеревоНоменклатуры.Развернуть(ИдентификаторСтроки, Истина);		
	КонецЦикла;	
КонецПроцедуры

&НаСервере
Процедура ПриИзмененииТипаРазукомплектацииНаСервере()
	Объект.КарточкаНоменклатурыКомплекта = Справочники.КарточкиНоменклатуры.ПустаяСсылка();
	ДеревоНоменклатуры.ПолучитьЭлементы().Очистить();
	СохранитьДеревоНоменклатуры();
	ВывестиДеревоНоменклатуры();
КонецПроцедуры

&НаКлиенте
Процедура ТипРазукомплектацииПриИзменении(Элемент)
	ПриИзмененииТипаРазукомплектацииНаСервере();	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область БСП

// СтандартныеПодсистемы.Свойства
&НаСервере
Процедура СвойстваВыполнитьОтложеннуюИнициализацию()
	УправлениеСвойствами.ЗаполнитьДополнительныеРеквизитыВФорме(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЗависимостиДополнительныхРеквизитов()
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ПриИзмененииДополнительногоРеквизита(Элемент)
	УправлениеСвойствамиКлиент.ОбновитьЗависимостиДополнительныхРеквизитов(ЭтотОбъект);
КонецПроцедуры

&НаСервере
Процедура ОбновитьЭлементыДополнительныхРеквизитов()
	
	УправлениеСвойствами.ОбновитьЭлементыДополнительныхРеквизитов(ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_СвойстваВыполнитьКоманду(ЭлементИлиКоманда, НавигационнаяСсылка = Неопределено, СтандартнаяОбработка = Неопределено)
    УправлениеСвойствамиКлиент.ВыполнитьКоманду(ЭтотОбъект, ЭлементИлиКоманда, СтандартнаяОбработка);
КонецПроцедуры
// Конец СтандартныеПодсистемы.Свойства

// СтандартныеПодсистемы.ПодключаемыеКоманды
&НаКлиенте
Процедура Подключаемый_ВыполнитьКоманду(Команда)
	ПодключаемыеКомандыКлиент.ВыполнитьКоманду(ЭтотОбъект, Команда, Объект);
КонецПроцедуры

&НаСервере
Процедура Подключаемый_ВыполнитьКомандуНаСервере(Контекст, Результат) Экспорт
	ПодключаемыеКоманды.ВыполнитьКоманду(ЭтотОбъект, Контекст, Объект, Результат);
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбновитьКоманды()
	ПодключаемыеКомандыКлиентСервер.ОбновитьКоманды(ЭтотОбъект, Объект);
КонецПроцедуры
// Конец СтандартныеПодсистемы.ПодключаемыеКоманды

#КонецОбласти

&НаСервере
Процедура УстановитьВидимостьДоступность()
	
	Элементы.ДеревоНоменклатурыСерийныйНомер.Видимость 		= Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка;
	Элементы.ДеревоНоменклатурыИнвентарныйНомер.Видимость 	= Элементы.ДеревоНоменклатурыОтображатьИнвентарныеИСерийныеНомера.Пометка;
	
КонецПроцедуры

&НаСервереБезКонтекста
// Получает набор данных с сервера для процедуры ДатаПриИзменении.
//
Функция ПолучитьДанныеДатаПриИзменении(ДокументСсылка, ДатаНовая, ДатаПередИзменением)
	
	РазностьДат = УправлениеITОтделом8УФ.ПроверитьНомерДокумента(ДокументСсылка, ДатаНовая, ДатаПередИзменением);
	
	СтруктураДанные = Новый Структура;	
	СтруктураДанные.Вставить("РазностьДат",	РазностьДат);
	
	Возврат СтруктураДанные;
	
КонецФункции // ПолучитьДанныеДатаПриИзменении()

&НаСервере
// Сохранения дерева номенклатуры
Процедура СохранитьДеревоНоменклатуры(ТекущийОбъект = Неопределено)
	
	Если ТекущийОбъект = Неопределено Тогда
		ТекОбъект = РеквизитФормыВЗначение("Объект");
	Иначе
		ТекОбъект = ТекущийОбъект;
	КонецЕсли;
	
	ДЗ = РеквизитФормыВЗначение("ДеревоНоменклатуры");
	
	ОбработкаТабличныхЧастей.СохранитьДеревоНоменклатуры(ДЗ, ТекОбъект.Номенклатура);
	
	Если ТекущийОбъект = Неопределено Тогда
		ЗначениеВДанныеФормы(ТекОбъект, Объект);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СохранитьПодчиненнуюНоменклатуру(Отказ, ТекущийОбъект, СтрокаДерева)
	Для Каждого Строки Из СтрокаДерева.Строки Цикл
		Если НЕ ЗначениеЗаполнено(Строки.КарточкаНоменклатуры) Тогда
			ТекстСообщения = СтрШаблон(НСтр("ru = 'Для номенклатуры ""%1"" в документе не указана карточка'"), Строки.Номенклатура);
			УправлениеITОтделом8УФ.СообщитьОбОшибке(Объект,	ТекстСообщения,,, "ДеревоНоменклатуры",	Отказ);
			Возврат;
		КонецЕсли;
		
		НоваяСтрока 						= ТекущийОбъект.Номенклатура.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строки);
		Если ЗначениеЗаполнено(Строки.Родитель) Тогда
			НоваяСтрока.Партия 				= Строки.Родитель.КарточкаНоменклатуры;
		КонецЕсли;
		СохранитьПодчиненнуюНоменклатуру(Отказ, ТекущийОбъект, Строки);
	КонецЦикла;
КонецПроцедуры

&НаСервере
// Вывод дерева номенклатуры
Процедура ВывестиДеревоНоменклатуры()
	
	ТЗ = Объект.Номенклатура.Выгрузить();
	ТЗ.Колонки.Добавить("НавСсылка");
	Для каждого Строки Из ТЗ Цикл
		Строки.НавСсылка = УправлениеITОтделом8УФПовтИсп.ПолучитьНавСсылкуНоменклатуры(Строки.Номенклатура);
	КонецЦикла;
	ДЗ = РеквизитФормыВЗначение("ДеревоНоменклатуры");
	ДЗ.Строки.Очистить();	
	УправлениеITОтделом8УФ.ВывестиДеревоНоменклатуры(ДЗ, ТЗ);
	ЗначениеВДанныеФормы(ДЗ, ДеревоНоменклатуры);
		
КонецПроцедуры

&НаСервере
Процедура ОбновитьНумерациюВДеревеЗначенийНаСервере()
	
	ОбработкаТабличныхЧастей.ОбновитьНумерациюВДереве(ДеревоНоменклатуры);
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьИнвентарныеИСерийныеНомераНаСервере()
	ДЗ = РеквизитФормыВЗначение("ДеревоНоменклатуры");
	УправлениеITОтделом8УФ.ОбновитьИнвентарныеИСерийныеНомера(ДЗ);
	ЗначениеВДанныеФормы(ДЗ, ДеревоНоменклатуры);
КонецПроцедуры

&НаСервере
Процедура ОбновитьКомплектациюНаСервере()
	
	Комплект = Объект.КарточкаНоменклатурыКомплекта;
	
	ДЗ = РеквизитФормыВЗначение("ДеревоНоменклатуры");
	ДЗ.Строки.Очистить();
	Объект.Номенклатура.Очистить();
		
	Если Комплект = Неопределено ИЛИ Комплект.Пустая() ИЛИ НЕ Комплект.Владелец.ВидНоменклатуры.МожетИметьКомплектующие Тогда
		ЗначениеВДанныеФормы(ДЗ, ДеревоНоменклатуры);
		Возврат;
	КонецЕсли;
	
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("Номенклатура", Новый ОписаниеТипов("СправочникСсылка.Номенклатура"));
	ТЗ.Колонки.Добавить("КарточкаНоменклатуры", Новый ОписаниеТипов("СправочникСсылка.КарточкиНоменклатуры"));
	ТЗ.Колонки.Добавить("Партия", Новый ОписаниеТипов("СправочникСсылка.КарточкиНоменклатуры"));
	ТЗ.Колонки.Добавить("Количество", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(15, 3, ДопустимыйЗнак.Любой)));
	ТЗ.Колонки.Добавить("Сумма", Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(15, 2, ДопустимыйЗнак.Любой)));
	ТЗ.Колонки.Добавить("НавСсылка");
	ТЗ.Колонки.Добавить("ЕдиницаИзмерения");
	ТЗ.Колонки.Добавить("Разбиение", Новый ОписаниеТипов("Булево"));
	
	Если Объект.ТипРазукомплектации = Перечисления.ТипыРазукомплектации.РазбитьКомплект Тогда
		
		// Выгружаем из регистра Комплектация.
		Запрос = Новый Запрос();
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ВЫБОР
			|		КОГДА ТИПЗНАЧЕНИЯ(КомплектацияОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
			|			ТОГДА КомплектацияОстатки.Номенклатура.Владелец
			|		ИНАЧЕ КомплектацияОстатки.Номенклатура
			|	КОНЕЦ КАК Номенклатура,
			|	ВЫБОР
			|		КОГДА ТИПЗНАЧЕНИЯ(КомплектацияОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
			|			ТОГДА КомплектацияОстатки.Номенклатура
			|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.КарточкиНоменклатуры.ПустаяСсылка)
			|	КОНЕЦ КАК КарточкаНоменклатуры,
			|	ВЫБОР
			|		КОГДА КомплектацияОстатки.Партия = &Комплект
			|			ТОГДА ЗНАЧЕНИЕ(Справочник.КарточкиНоменклатуры.ПустаяСсылка)
			|		ИНАЧЕ КомплектацияОстатки.Партия
			|	КОНЕЦ КАК Партия,
			|	КомплектацияОстатки.КоличествоОстаток КАК Количество,
			|	КомплектацияОстатки.СуммаОстаток КАК Сумма,
			|	КомплектацияОстатки.Номенклатура.ВидНоменклатуры.НавСсылка КАК НавСсылка,
			|	ВЫБОР
			|		КОГДА ТИПЗНАЧЕНИЯ(КомплектацияОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
			|			ТОГДА КомплектацияОстатки.Номенклатура.Владелец.ЕдиницаИзмерения
			|		ИНАЧЕ КомплектацияОстатки.Номенклатура.ЕдиницаИзмерения
			|	КОНЕЦ КАК ЕдиницаИзмерения,
			|	ЛОЖЬ КАК Разбиение
			|ИЗ
			|	РегистрНакопления.Комплектация.Остатки(&ДатаКон, Комплект = &Комплект) КАК КомплектацияОстатки";
		
		Запрос.УстановитьПараметр("Комплект", Комплект);
		Если Объект.Ссылка.Пустая() Тогда
			Запрос.УстановитьПараметр("ДатаКон", КонецДня(ТекущаяДатаСеанса()));
		Иначе
			Запрос.УстановитьПараметр("ДатаКон", Объект.Дата);
		КонецЕсли;	
		
		ТЗ = Запрос.Выполнить().Выгрузить();
		
		Для каждого Строки Из ТЗ Цикл
			Если НЕ ЗначениеЗаполнено(Строки.КарточкаНоменклатуры) Тогда
				Строки.КарточкаНоменклатуры = УправлениеITОтделом8УФПовтИсп.ПолучитьКарточкуНеВедетсяУчетПоКарточкамНоменклатуры(Строки.Номенклатура);			
			КонецЕсли;
			Строки.Разбиение = Истина;
		КонецЦикла;
		
		
	ИначеЕсли Объект.ТипРазукомплектации = Перечисления.ТипыРазукомплектации.РазбитьОбъединенныеКомплектующие Тогда
		// Выгружаем из регистра Остатки все, что входит в Комплект		
		ДобавитьДочернююНоменклатуру(ТЗ, Комплект);		
	КонецЕсли;
		
	УправлениеITОтделом8УФ.ВывестиДеревоНоменклатуры(ДЗ, ТЗ);		
	
	// Сортировка ДЗ
	ДЗ.Строки.Сортировать("Номенклатура,КарточкаНоменклатуры", Истина);
	УправлениеITОтделом8УФ.ОбновитьКлючиСтрокВДеревеЗначений(ДЗ);
	
	Для каждого Строки Из ТЗ Цикл
		НоваяСтрока = Объект.Номенклатура.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Строки);
	КонецЦикла;		
					
	ЗначениеВДанныеФормы(ДЗ, ДеревоНоменклатуры);	
		
КонецПроцедуры

&НаСервере
Процедура ДобавитьДочернююНоменклатуру(ТЗ, Комплект)
	
	Запрос = Новый Запрос();
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(ОстаткиОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
		|			ТОГДА ОстаткиОстатки.Номенклатура.Владелец
		|		ИНАЧЕ ОстаткиОстатки.Номенклатура
		|	КОНЕЦ КАК Номенклатура,
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(ОстаткиОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
		|			ТОГДА ОстаткиОстатки.Номенклатура
		|		ИНАЧЕ ЗНАЧЕНИЕ(Справочник.КарточкиНоменклатуры.ПустаяСсылка)
		|	КОНЕЦ КАК КарточкаНоменклатуры,
		|	ВЫБОР
		|		КОГДА ОстаткиОстатки.Партия = &ГоловнаяПартия
		|			ТОГДА ЗНАЧЕНИЕ(Справочник.КарточкиНоменклатуры.ПустаяСсылка)
		|		ИНАЧЕ ОстаткиОстатки.Партия
		|	КОНЕЦ КАК Партия,
		|	ОстаткиОстатки.КоличествоОстаток КАК Количество,
		|	ОстаткиОстатки.СуммаОстаток КАК Сумма,
		|	ОстаткиОстатки.Номенклатура.ВидНоменклатуры.НавСсылка КАК НавСсылка,
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(ОстаткиОстатки.Номенклатура) = ТИП(Справочник.КарточкиНоменклатуры)
		|			ТОГДА ОстаткиОстатки.Номенклатура.Владелец.ЕдиницаИзмерения
		|		ИНАЧЕ ОстаткиОстатки.Номенклатура.ЕдиницаИзмерения
		|	КОНЕЦ КАК ЕдиницаИзмерения
		|ИЗ
		|	РегистрНакопления.Остатки.Остатки(
		|			&ДатаКон,
		|			Организация = &Организация
		|				И МестоХранения = &МестоХранения
		|				И Партия = &Комплект) КАК ОстаткиОстатки";
	
	Запрос.УстановитьПараметр("Организация", Объект.Организация);
	Запрос.УстановитьПараметр("МестоХранения", Объект.МестоХранения);
	Запрос.УстановитьПараметр("Комплект", Комплект);
	Запрос.УстановитьПараметр("ГоловнаяПартия", Объект.КарточкаНоменклатурыКомплекта);
	Если Объект.Ссылка.Пустая() Тогда
		Запрос.УстановитьПараметр("ДатаКон", КонецДня(ТекущаяДатаСеанса()));
	Иначе
		Запрос.УстановитьПараметр("ДатаКон", Объект.Дата);
	КонецЕсли;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НоваяСтрока = ТЗ.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Выборка);		
		Если ЗначениеЗаполнено(НоваяСтрока.КарточкаНоменклатуры) Тогда
			ДобавитьДочернююНоменклатуру(ТЗ, Выборка.КарточкаНоменклатуры);
		Иначе
			НоваяСтрока.КарточкаНоменклатуры = УправлениеITОтделом8УФПовтИсп.ПолучитьКарточкуНеВедетсяУчетПоКарточкамНоменклатуры(Выборка.Номенклатура);			
		КонецЕсли;
		НоваяСтрока.Разбиение = Истина;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ТекущаяДатаНаСервере()
	
	Возврат ТекущаяДатаСеанса();
	
КонецФункции

#Область УчетОстатковКонтрагентов

&НаКлиенте
Процедура Подключаемый_НачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
			
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикНачалоВыбора(ЭтаФорма, Объект.Организация, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_АвтоПодбор(Элемент, Текст, ДанныеВыбора, ПараметрыПолученияДанных, Ожидание, СтандартнаяОбработка)
		
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикАвтоПодбор(ЭтаФорма, 
				"Организация",
				Текст, 
				ДанныеВыбора,
				Ожидание,
				СтандартнаяОбработка);
				
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_Очистка(Элемент, СтандартнаяОбработка)	
	
КонецПроцедуры

&НаКлиенте
Процедура Подключаемый_ОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)	
		
	УправлениеITОтделом8УФКлиент.ВыполнитьОбработчикОбработкаВыбора(ЭтаФорма, 
				"Организация", 
				Объект.Организация,
				Новый ОписаниеОповещения("ПослеОбработкиВыбора", ЭтотОбъект),
				ВыбранноеЗначение,
				СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеОбработкиВыбора(Результат, ДополнительныеПараметры) Экспорт
	
	ОрганизацияПриИзменении(Неопределено);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти