﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Параметры для вызова ВнешниеКомпонентыСервер.ПодключитьКомпоненту.
//
// Возвращаемое значение:
//  Структура - со свойствами:
//    * ИдентификаторыСозданияОбъектов - Массив Из Строка - идентификаторы экземпляров модуля объекта,
//              используется только для компонент, у которых есть несколько идентификаторов создания объектов.
//              При задании параметр Идентификатор будет использоваться только для определения компоненты.
//
Функция ПараметрыПодключения() Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("ИдентификаторыСозданияОбъектов", Новый Массив);
	
	Возврат Параметры;
	
КонецФункции

// Подключает на сервере 1С:Предприятия внешнюю компоненту из хранилища внешних компонент,
// выполненную по технологии Native API или COM.
// В модели сервиса разрешено только подключение общих внешних компонент, одобренных администратором сервиса.
//
// Параметры:
//  Идентификатор - Строка - идентификатор объекта внешней компоненты.
//  Версия        - Строка - версия компоненты.
//  ПараметрыПодключения - см. ВнешниеКомпонентыСервер.ПодключитьКомпоненту.
//
// Возвращаемое значение:
//   Структура - результат подключения компоненты:
//     * Подключено - Булево - признак подключения;
//     * ПодключаемыйМодуль - AddIn - экземпляр объекта внешней компоненты;
//                          - ФиксированноеСоответствие - экземпляры объектов внешней компоненты,
//                            указанные в ПараметрыПодключения.ИдентификаторыСозданияОбъектов;
//                            ** Ключ - Строка - идентификатор,
//                            ** Значение - AddIn - экземпляр объекта внешней компоненты.
//     * ОписаниеОшибки - Строка - краткое описание ошибки. 
//
Функция ПодключитьКомпоненту(Знач Идентификатор, Версия = Неопределено, ПараметрыПодключения = Неопределено) Экспорт
	
	РезультатПроверки = ВнешниеКомпонентыСлужебный.ПроверитьПодключениеКомпоненты(Идентификатор, Версия, ПараметрыПодключения);
	Если Не ПустаяСтрока(РезультатПроверки.ОписаниеОшибки) Тогда
		Результат = Новый Структура;
		Результат.Вставить("Подключено", Ложь);
		Результат.Вставить("ПодключаемыйМодуль", Неопределено);
		Результат.Вставить("ОписаниеОшибки", РезультатПроверки.ОписаниеОшибки);
		Возврат Результат;		
	КонецЕсли;	
	Возврат ОбщегоНазначения.ПодключитьКомпонентуПоИдентификатору(РезультатПроверки.Идентификатор, РезультатПроверки.Местоположение);
	
КонецФункции

#Область ДляВызоваИзДругихПодсистем

// ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент

// Возвращает таблицу описаний внешних компонент, которые требуется обновлять автоматически с Портала 1С:ИТС.
//
// Возвращаемое значение:
//  см. ПолучениеВнешнихКомпонент.ОписаниеВнешнихКомпонент
//          подсистемы ПолучениеВнешнихКомпонент Библиотеки интернет-поддержки пользователей (БИП).
//
Функция АвтоматическиОбновляемыеКомпоненты() Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент") Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ВнешниеКомпоненты.Идентификатор КАК Идентификатор,
			|	ВнешниеКомпоненты.Версия КАК Версия
			|ИЗ
			|	Справочник.ВнешниеКомпоненты КАК ВнешниеКомпоненты
			|ГДЕ
			|	ВнешниеКомпоненты.ОбновлятьСПортала1СИТС";
		
		РезультатЗапроса = Запрос.Выполнить();
		Выборка = РезультатЗапроса.Выбрать();
		
		МодульПолучениеВнешнихКомпонент = ОбщегоНазначения.ОбщийМодуль("ПолучениеВнешнихКомпонент");
		ОписаниеВнешнихКомпонент = МодульПолучениеВнешнихКомпонент.ОписаниеВнешнихКомпонент();
		
		Пока Выборка.Следующий() Цикл
			ОписаниеКомпоненты = ОписаниеВнешнихКомпонент.Добавить();
			ОписаниеКомпоненты.Идентификатор = Выборка.Идентификатор;
			ОписаниеКомпоненты.Версия = Выборка.Версия;
		КонецЦикла;
		
		Возврат ОписаниеВнешнихКомпонент;
		
	Иначе
		ВызватьИсключение 
			НСтр("ru = 'Ожидается существование подсистемы ""ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент""'");
	КонецЕсли;
	
КонецФункции

// Выполняет обновление внешних компонент.
//
// Параметры:
//  ДанныеВнешнихКомпонент - ТаблицаЗначений - таблица обновляемых компонент.
//    ** Идентификатор - Строка - идентификатор.
//    ** Версия - Строка - версия.
//    ** ДатаВерсии - Строка - дата версии.
//    ** Наименование - Строка - наименование.
//    ** ИмяФайла - Строка - имя файла.
//    ** АдресФайла - Строка - адрес файла.
//    ** КодОшибки - Строка - код ошибки.
//  АдресРезультата - Строка - (необязательный) адрес временного хранилища.
//      Если указан, в него будет помещено описание результата операции.
//
Процедура ОбновитьВнешниеКомпоненты(ДанныеВнешнихКомпонент, АдресРезультата = Неопределено) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент") Тогда
	
		Результат = "";
		
		Запрос = Новый Запрос;
		Запрос.Текст =
			"ВЫБРАТЬ
			|	ВнешниеКомпоненты.Ссылка КАК Ссылка,
			|	ВнешниеКомпоненты.Идентификатор КАК Идентификатор,
			|	ВнешниеКомпоненты.ДатаВерсии КАК ДатаВерсии
			|ИЗ
			|	Справочник.ВнешниеКомпоненты КАК ВнешниеКомпоненты
			|ГДЕ
			|	ВнешниеКомпоненты.Идентификатор В(&Идентификаторы)";
		
		Запрос.УстановитьПараметр("Идентификаторы", ДанныеВнешнихКомпонент.ВыгрузитьКолонку("Идентификатор"));
		
		РезультатЗапроса = Запрос.Выполнить();
		Выборка = РезультатЗапроса.Выбрать();
		
		// Обход результата запроса.
		Для каждого СтрокаРезультата Из ДанныеВнешнихКомпонент Цикл
			
			ПредставлениеКомпоненты = ВнешниеКомпонентыСлужебный.ПредставлениеКомпоненты(
				СтрокаРезультата.Идентификатор, 
				СтрокаРезультата.Версия);
			
			КодОшибки = СтрокаРезультата.КодОшибки;
			
			Если ЗначениеЗаполнено(КодОшибки) Тогда
				
				Если КодОшибки = "АктуальнаяВерсия" Тогда
					Результат = Результат + ПредставлениеКомпоненты + " - " + НСтр("ru = 'Актуальная версия.'") + Символы.ПС;
					Продолжить;
				КонецЕсли;
				
				ИнформацияОбОшибке = "";
				Если КодОшибки = "ОтсутствуетКомпонента" Тогда 
					ИнформацияОбОшибке = НСтр("ru = 'В сервисе внешних компонент не обнаружена внешняя компонента'");
				ИначеЕсли КодОшибки = "ФайлНеЗагружен" Тогда 
					ИнформацияОбОшибке = НСтр("ru = 'При попытке загрузить файл внешней компоненты из сервиса, возникла ошибка'");
				КонецЕсли;
				
				ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'При загрузке внешней компоненты %1 возникала ошибка:
					           |%2'"),
					ПредставлениеКомпоненты,
					ИнформацияОбОшибке);
				
				Результат = Результат + ПредставлениеКомпоненты + " - " + ИнформацияОбОшибке + Символы.ПС;
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
					ОбщегоНазначения.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Ошибка,,,
					ТекстОшибки);
				
				Продолжить;
			КонецЕсли;
			
			ДвоичныеДанные = ПолучитьИзВременногоХранилища(СтрокаРезультата.АдресФайла);
			Информация = ВнешниеКомпонентыСлужебный.ИнформацияОКомпонентеИзФайла(ДвоичныеДанные, Ложь);
			
			Если Не Информация.Разобрано Тогда 
				
				Результат = Результат + ПредставлениеКомпоненты + " - " + Информация.ОписаниеОшибки + Символы.ПС;
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
					ОбщегоНазначения.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Ошибка,,, Информация.ОписаниеОшибки);
					
				Продолжить;
			КонецЕсли;
			
			// Поиск ссылки.
			Отбор = Новый Структура("Идентификатор", СтрокаРезультата.Идентификатор);
			Если Выборка.НайтиСледующий(Отбор) Тогда 
				
				// Когда уже загружена компонента по дате более свежая, чем на Портале 1С:ИТС, обновление не следует выполнять.
				Если Выборка.ДатаВерсии > СтрокаРезультата.ДатаВерсии Тогда 
					Продолжить;
				КонецЕсли;
				
				НачатьТранзакцию();
				Попытка
					
					Блокировка = Новый БлокировкаДанных;
					ЭлементБлокировки = Блокировка.Добавить("Справочник.ВнешниеКомпоненты");
					ЭлементБлокировки.УстановитьЗначение("Ссылка", Выборка.Ссылка);
					Блокировка.Заблокировать();
					
					Объект = Выборка.Ссылка.ПолучитьОбъект();
					Объект.Заблокировать();
					
					ЗаполнитьЗначенияСвойств(Объект, Информация.Реквизиты); // По данным манифеста.
					ЗаполнитьЗначенияСвойств(Объект, СтрокаРезультата);     // По данным с сайта.
					
					Объект.ДополнительныеСвойства.Вставить("ДвоичныеДанныеКомпоненты", Информация.ДвоичныеДанные);
					
					Объект.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Загружена с Портала 1С:ИТС. %1.'"),
						ТекущаяДатаСеанса());
					
					Объект.Записать();
					
					Результат = Результат + ПредставлениеКомпоненты
						+ " - " + НСтр("ru = 'Успешно обновлена.'") + Символы.ПС;
					
					ЗафиксироватьТранзакцию();
				Исключение
					ОтменитьТранзакцию();
					Результат = Результат + ПредставлениеКомпоненты
						+ " - " + КраткоеПредставлениеОшибки(ИнформацияОбОшибке()) + Символы.ПС;
					
					ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
							ОбщегоНазначения.КодОсновногоЯзыка()),
						УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				КонецПопытки;
				
			КонецЕсли;
			
		КонецЦикла;
		
		Если ЗначениеЗаполнено(АдресРезультата) Тогда 
			ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
		КонецЕсли;
		
	Иначе
		ВызватьИсключение 
			НСтр("ru = 'Ожидается существование подсистемы ""ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент""'");
	КонецЕсли;
	
КонецПроцедуры

// Структура параметров для см. процедуру ОбновитьОбщуюКомпоненту.
//
// Возвращаемое значение:
//  Структура - коллекция параметров:
//      * Идентификатор - Строка - идентификатор.
//      * Версия - Строка - версия.
//      * ДатаВерсии - Дата - дата версии.
//      * Наименование - Строка - наименование.
//      * ИмяФайла - Строка - имя файла.
//      * ПутьКФайлу - Строка - путь к файлу.
//
Функция ОписаниеПоставляемойОбщейКомпоненты() Экспорт
	
	Описание = Новый Структура;
	Описание.Вставить("Идентификатор");
	Описание.Вставить("Версия");
	Описание.Вставить("ДатаВерсии");
	Описание.Вставить("Наименование");
	Описание.Вставить("ИмяФайла");
	Описание.Вставить("ПутьКФайлу");
	Возврат Описание;
	
КонецФункции

// Выполняет обновление общих внешних компонент.
//
// Параметры:
//  ОписаниеКомпоненты - см. функцию ОписаниеПоставляемойОбщейКомпоненты.
//
Процедура ОбновитьОбщуюКомпоненту(ОписаниеКомпоненты) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ВнешниеКомпонентыВМоделиСервиса") Тогда
		МодульВнешниеКомпонентыВМоделиСервисаСлужебный = ОбщегоНазначения.ОбщийМодуль("ВнешниеКомпонентыВМоделиСервисаСлужебный");
		МодульВнешниеКомпонентыВМоделиСервисаСлужебный.ОбновитьОбщуюКомпоненту(ОписаниеКомпоненты);
	КонецЕсли;
	
КонецПроцедуры

// Конец ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент

#КонецОбласти

#КонецОбласти
