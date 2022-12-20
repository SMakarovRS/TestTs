﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	СЛС.ПриСозданииНаСервере(Объект, Отказ, СтандартнаяОбработка, Параметры, ЭтаФорма);	
	
	Если Не Пользователи.ЭтоПолноправныйПользователь() ИЛИ НЕ ПравоДоступа("Добавление", Метаданные.Справочники.Пользователи) Тогда
		ОбщегоНазначения.СообщитьПользователю(НСтр("ru = 'Внимание. Похоже, недостаточно прав для управления учетными записями пользователей. Необходимы права администратора или полные права.'"), СтатусСообщения.Важное);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "Запись_ПрофильИмпортаИзAD" Тогда
		Если ЗначениеЗаполнено(ПрофильИмпортаИзAD) И ПрофильИмпортаИзAD = Источник Тогда
			УстановитьНастройкиПодключения(ПрофильИмпортаИзAD);
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	УстановитьНастройкиПодключения(ПрофильИмпортаИзAD);		
	Элементы.ФормаВключатьПодчиненные.Пометка 		= ПросмотрПодчиненных;
	Элементы.ОбновлятьСписокПользователей.Пометка 	= ОбновлятьСписокПользователейПриАктивизацииСтроки;
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	#Если ВебКлиент Тогда		
		Элементы.Обновить.Доступность = Ложь;
		ПоказатьПредупреждение( , НСтр("ru = 'В режиме ""Веб-клиента"" подключение к AD недоступно.'"));		
	#КонецЕсли	
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КонтекстыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)	

	ТекСтр 	= Контексты.НайтиПоИдентификатору(ВыбраннаяСтрока);	
	СС 		= ПолучитьLDAPЗапросПоТекущемуЗначениюДереваAD(ТекСтр.LDAP);		 
	ЗаполнитьТаблицуПользователей(СС, Элементы.ФормаВключатьПодчиненные.Пометка);
	
КонецПроцедуры

&НаКлиенте
Процедура КонтекстыПриАктивизацииСтроки(Элемент)	
	
	Если Не ОбновлятьСписокПользователейПриАктивизацииСтроки Тогда
		Возврат;
	КонецЕсли;	
	
	ПодключитьОбработчикОжидания("КонтекстыПриАктивизацииСтрокиОбработчикОжидания", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ПрофильИмпортаИзADПриИзменении(Элемент)
	
	УстановитьНастройкиПодключения(ПрофильИмпортаИзAD);	
	УстановитьВидимостьДоступность();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОчиститьРезультаты(Команда)
	
	Результаты.Очистить();
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьПользователейКлиент(Команда)
		
	ТекстСообщенияОшибки = ОшибкиВПрофиле();
	
	Если ЗначениеЗаполнено(ТекстСообщенияОшибки) Тогда
		ПоказатьПредупреждение(, ТекстСообщенияОшибки);
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	// Проверка наличия выбранных строк таблицы пользователей AD.
	ВыбранныеСтрокиТаблицыПользователей = ТаблицаПользователей.НайтиСтроки(Новый Структура("Исправить", Истина));
	Если ВыбранныеСтрокиТаблицыПользователей.Количество() = 0 Тогда 
		ПоказатьПредупреждение(, НСтр("ru = 'Не выбрано ни одного пользователя для загрузки.'"));
		Возврат;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗагрузитьПользователейКлиентПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Будет выполнен импорт данных согласно настроек профиля. Продолжить?'"), РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсеФлажки(Команда)
	
	Для каждого Запись Из ТаблицаПользователей Цикл
		Запись.Исправить = Истина;
	КонецЦикла; 

КонецПроцедуры

&НаКлиенте
Процедура СнятьВсеФлажки(Команда)
	
	Для каждого Запись Из ТаблицаПользователей Цикл
		Запись.Исправить = Ложь;
	КонецЦикла; 
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	ЗагрузитьНаКлиенте();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемДоменПочты(Команда)
	
	Количество = 0;
	
	Для каждого Юзер Из ТаблицаПользователей Цикл		
		Если Юзер.Исправить Тогда
			Количество = Количество + 1;
		КонецЕсли;	
	КонецЦикла;
	
	Если Количество = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Не выбрано ни одного пользователя AD.'"));
		Возврат;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("УстановитьВсемДоменПочтыПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Для выбранных пользователей AD будет заполнен электронный адрес вида ""Аккаунт Windows@Имя домена"". Продолжить?'"),
		РежимДиалогаВопрос.ДаНет);
		
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемПодразделение(Команда)
	
	Количество = 0;
	
	Для каждого Юзер Из ТаблицаПользователей Цикл		
		Если Юзер.Исправить Тогда
			Количество = Количество + 1;
		КонецЕсли;	
	КонецЦикла;
	
	Если Количество = 0 Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Не выбрано ни одного пользователя AD.'"));
		Возврат;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("УстановитьВсемПодразделениеПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Для выбранных пользователей AD будет заполнено подразделение. Продолжить?'"), РежимДиалогаВопрос.ДаНет);
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемПодразделениеПослеВопроса(Результат, ДополнительныеПараметры)Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Подразделение = Неопределено;
	ОткрытьФорму("Справочник.Подразделения.ФормаВыбора",,,,,, Новый ОписаниеОповещения("УстановитьВсемПодразделениеЗавершение", ЭтаФорма), РежимОткрытияОкнаФормы.БлокироватьВесьИнтерфейс);	
	
КонецПроцедуры	

&НаКлиенте
Процедура ВыбратьНовыхПользователейAD(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ВыбратьНовыхПользователейADПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Будут выбраны те пользователи AD, которые еще не загружались в ""1С"". Продолжить?'"),
		РежимДиалогаВопрос.ДаНет);
		
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьНовыхПользователейADПослеВопроса(Результат, ДополнительныеПараметры)Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Юзер Из ТаблицаПользователей Цикл
		Юзер.Исправить = Не ЗначениеЗаполнено(Юзер.ИдентификаторПользователяИБ);
	КонецЦикла;

КонецПроцедуры	

&НаКлиенте
Процедура ОтключитьПользователей(Команда)
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ОтключитьПользователейПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'ВНИМАНИЕ. Выбранным пользователям в программе будет установлен признак ""Недействителен"". Продолжить?'"),
			РежимДиалогаВопрос.ДаНет);
			
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьПользователейПослеВопроса(Результат, ДополнительныеПараметры)Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	ВыбранныеСтрокиТаблицыПользователей = ТаблицаПользователей.НайтиСтроки(Новый Структура("Исправить", Истина));
	
	// Проверка выбора пользователей, уже имеющих аккаунт в 1с.
	ОтмеченыСуществующиеПользователи = Ложь;
	Для Каждого Стр Из ВыбранныеСтрокиТаблицыПользователей Цикл
		Если ЗначениеЗаполнено(Стр.ИдентификаторПользователяИБ) Тогда
			ОтмеченыСуществующиеПользователи = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если Не ОтмеченыСуществующиеПользователи Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Не выбрано ни одного пользователя с уже существующим аккаунтом 1С.'"));
		Возврат;
	КонецЕсли;
	
	// Загрузка.
	Состояние(НСтр("ru = 'Отключение пользователей...'"));
	ЕстьОшибки = Ложь;
	ОтключитьПользователейСервер(ЕстьОшибки);
	Если ЕстьОшибки Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Ошибки при отключении пользователей. См. окно сообщений.'"), , НСтр("ru = 'Внимание'"))
	Иначе
		ПоказатьПредупреждение(, НСтр("ru = 'Отключение пользователей успешно завершено.'"));
	КонецЕсли;
	
КонецПроцедуры	

&НаКлиенте
Процедура ОткрытьПользователей(Команда)
	
	Для Каждого Стр Из Элементы.Учетки.ВыделенныеСтроки Цикл
		НайденныйПользователь = УправлениеITОтделом8УФ.НайтиПользователя1С(ТаблицаПользователей.НайтиПоИдентификатору(Стр).ИдентификаторПользователяИБ);
		Если НайденныйПользователь <> Неопределено Тогда
			ПоказатьЗначение(, НайденныйПользователь);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ВключатьПодчиненные(Команда)
	
	ПросмотрПодчиненных 					  = Не ПросмотрПодчиненных;
	Элементы.ФормаВключатьПодчиненные.Пометка = ПросмотрПодчиненных;	
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновлятьСписокПользователей(Команда)
	
	ОбновлятьСписокПользователейПриАктивизацииСтроки = Не ОбновлятьСписокПользователейПриАктивизацииСтроки;
	Элементы.ОбновлятьСписокПользователей.Пометка 	 = ОбновлятьСписокПользователейПриАктивизацииСтроки;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьПрофиль(Команда)
	
	УстановитьНастройкиПодключения(ПрофильИмпортаИзAD);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьДомен(Команда)
	
	Количество = 0;
	
	Для каждого Юзер Из ТаблицаПользователей Цикл		
		Если Юзер.Исправить Тогда
			Количество = Количество + 1;
		КонецЕсли;	
	КонецЦикла;
	
	Если Количество = 0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Не выбрано ни одного пользователя AD.'"));
		Возврат;
	КонецЕсли;
	
	ОписаниеОповещения = Новый ОписаниеОповещения("УстановитьВсемДоменПослеВопроса", ЭтотОбъект);
	ПоказатьВопрос(ОписаниеОповещения, НСтр("ru = 'Для выбранных пользователей AD будет заполнен домен для возможности аутентификации ОС (\\mydomen\ИмяПользователя). Продолжить?'"), РежимДиалогаВопрос.ДаНет);

КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемДоменПослеВопроса(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли; 
	
	стрДомен = "ИмяДомена";
	ПоказатьВводЗначения(Новый ОписаниеОповещения("УстановитьВсемДоменЗавершение", ЭтаФорма, 
		Новый Структура("стрДомен", стрДомен)), стрДомен, НСтр("ru = 'Введите имя домена'"));
	                                                                                                                                           
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемДоменЗавершение(Значение, ДополнительныеПараметры) Экспорт
	
	стрДомен = ?(Значение = Неопределено, ДополнительныеПараметры.стрДомен, Значение);
	
	Для Каждого Юзер Из ТаблицаПользователей Цикл		
		Если Юзер.Исправить Тогда
			Юзер.Домен = стрДомен;			
		КонецЕсли;	
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ОшибкиВПрофиле()
	
	ТекстСообщения = "";
	
	Если Не ПрофильИмпортаИзAD.МестаХраненияСоздаватьМестаХранения 
		И Не ПрофильИмпортаИзAD.ОрганизацииСоздаватьОрганизации
		И Не ПрофильИмпортаИзAD.ПодразделенияСоздаватьПодразделения
		И Не ПрофильИмпортаИзAD.ПользователиСоздаватьПользователей		
		И Не ПрофильИмпортаИзAD.ФизЛицаСоздаватьФизЛицо Тогда
		ТекстСообщения = НСтр("ru = 'В выбранном профиле не указаны объекты для загрузки.'");
	КонецЕсли;
	
	Возврат ТекстСообщения;
	
КонецФункции

&НаКлиенте
Процедура ЗагрузитьПользователейКлиентПослеВопроса(Результат, ДополнительныеПараметры)Экспорт
	
	Если Результат <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	ЗагрузитьПользователейКлиентФрагмент();

КонецПроцедуры

&НаСервере
Процедура УстановитьВидимостьДоступность()
	
	Элементы.СоздатьПользователей.Доступность = ЗначениеЗаполнено(ПрофильИмпортаИзAD);
	
КонецПроцедуры	

&НаСервере
Процедура ЗагрузитьПользователейКлиентФрагмент()   
    
	ВыбранныеСтрокиТаблицыПользователей = ТаблицаПользователей.НайтиСтроки(Новый Структура("Исправить", Истина));	
	ТаблицаПользователейАД 				= УправлениеITОтделом8УФ.СтруктураТаблицыПользователейАД();
	
	Для Каждого СтрокаМассива Из ВыбранныеСтрокиТаблицыПользователей Цикл
		НоваяСтрока = ТаблицаПользователейАД.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаМассива); 
	КонецЦикла;	
	
	ТЗРезультаты = УправлениеITОтделом8УФ.ВыполнитьИмпортИзАД(ТаблицаПользователейАД, ПрофильИмпортаИзAD, Истина);
	
	Если ТЗРезультаты.Количество() > 0 Тогда
		Результаты.Загрузить(ТЗРезультаты);
	КонецЕсли;	
	
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаСтраницы.ПодчиненныеЭлементы.СтраницаРезультат;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемДоменПочтыПослеВопроса(Результат, ДополнительныеПараметры)Экспорт
	
	Если Результат<>КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;		
	
	стрДомен = "mail.ru";
	ПоказатьВводЗначения(Новый ОписаниеОповещения("УстановитьВсемДоменПочтыЗавершение", ЭтаФорма, 
		Новый Структура("стрДомен", стрДомен)), стрДомен, НСтр("ru = 'Введите имя домена'"));
	
КонецПроцедуры	

&НаКлиенте
Функция ПолучитьLDAPЗапросПоТекущемуЗначениюДереваAD(СтрокаДерева)
		
	Если ПодключениеИспользоватьУчетнуюЗапись Тогда
		мПорт	 = ?(ЗначениеЗаполнено(ПодключениеПорт), СокрЛП(ПодключениеПорт), "389");	
		LDAP_HDR = "LDAP://" + ПодключениеКонтроллерДомена + ":" + мПорт + "/";
	Иначе
		LDAP_HDR = "LDAP://";		
	КонецЕсли;	
	
	LDAPText = LDAP_HDR + СтрокаДерева; 
	
	Возврат LDAPText;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьТаблицуПользователей(LDAPText, Рекурсивно = Ложь) Экспорт	
		
	ТаблицаПользователей.Очистить();
	АтрибутДР 				= "";	
	
	Если ПустаяСтрока(LDAPText) Тогда
		Возврат;
	КонецЕсли;
	
	ПодстрокаЗапроса = ">;(&(objectCategory=person)(objectClass=user));ADsPath,DisplayName,mail,telephoneNumber,sAMAccountName,department,company,title,UserAccountControl,thumbnailPhoto;";
	
	Если ФизЛицаЗагружатьДатуРождения И ЗначениеЗаполнено(СокрЛП(ФизЛицаИмяАтрибутаДатаРождения)) Тогда
		АтрибутДР 		 = СокрЛП(ФизЛицаИмяАтрибутаДатаРождения);
		ПодстрокаЗапроса = Сред(ПодстрокаЗапроса, 1, СтрДлина(ПодстрокаЗапроса) - 1) + "," + АтрибутДР + ";";
	КонецЕсли;	
	
	Если ПодключениеИспользоватьУчетнуюЗапись Тогда
		Попытка
			
			Порт				= ?(ЗначениеЗаполнено(ПодключениеПорт), СокрЛП(ПодключениеПорт), "389");			
			СтрокаПодключения 	= "Provider=ADSDSOObject;User Id=" + ПодключениеДомен + "\" + ПодключениеУчетнаяЗапись + ";Password=" + ПодключениеПароль + ";";			
			
			conn				= Новый COMОбъект("ADODB.Connection");
			conn.cursorLocation = 3;
			conn.Open(СтрокаПодключения);			
			
			cmd = Новый COMОбъект("ADODB.Command");
			cmd.ActiveConnection = conn;
			cmd.Properties("Page Size").Value = 100;
			cmd.Properties("Cache Results").Value = True;						
			cmd.CommandText = "<" + СокрЛП(LDAPText) + ПодстрокаЗапроса + ?(Рекурсивно, "subtree", "onelevel");		
			rs = cmd.Execute();				
			
		Исключение			
			ТекстОшибки = ИнформацияОбОшибке();
			ОбщегоНазначенияКлиент.СообщитьПользователю(КраткоеПредставлениеОшибки(ТекстОшибки));
			Возврат;			
		КонецПопытки;
		
	Иначе	
		Попытка 
			conn = Новый COMОбъект("ADODB.Connection");
			conn.Provider = "ADSDSOObject";
			conn.Open("ADs Provider");
			
			cmd = Новый COMОбъект("ADODB.Command");
			cmd.ActiveConnection = conn;
			cmd.Properties("Page Size").Value = 100;
			cmd.Properties("Cache Results").Value = True;						
			cmd.CommandText = "<" + СокрЛП(LDAPText) + ПодстрокаЗапроса + ?(Рекурсивно, "subtree", "onelevel");		
			rs = cmd.Execute();
			
		Исключение
			ТекстОшибки = ИнформацияОбОшибке();
			ОбщегоНазначенияКлиент.СообщитьПользователю(КраткоеПредставлениеОшибки(ТекстОшибки));
			Возврат;			
		КонецПопытки;
	КонецЕсли;
	
	СтатусLDAPЗапроса = "";
	
	Сч = 0;
	Если rs.RecordCount > 0 Тогда
		Пока Не rs.EOF Цикл  
			
			Попытка
				АккаунтИмя 		= rs.Fields("sAMAccountName").Value;
				СтрПочта 		= rs.Fields("mail").Value;
				Представление 	= ?(ПустаяСтрока(rs.Fields("DisplayName").Value), АккаунтИмя, rs.Fields("DisplayName").Value);
				СтрТелефон 		= rs.Fields("telephoneNumber").Value;
				Подразделение	= rs.Fields("department").Value;
				ADsPath			= rs.Fields("ADsPath").Value;				
				Организация		= rs.Fields("company").Value;
				Должность		= rs.Fields("title").Value;
				Если ЗначениеЗаполнено(АтрибутДР) Тогда
					Попытка
						ДатаРождения	= rs.Fields(АтрибутДР).Value;
					Исключение
					КонецПопытки;	
				КонецЕсли;					
				
				Попытка
					Статус = УправлениеITОтделом8УФ.СтатусУчетнойЗаписи(rs.Fields("UserAccountControl").value);					
				Исключение
					Статус = 0;
				КонецПопытки;
				
			Исключение
				rs.MoveNext();
				Сч = Сч + 1;
				Продолжить;
			КонецПопытки;
			
			пСуществует = ложь;
			        
			Пользователь		= УправлениеITОтделом8УФ.НайтиПользователяИБ(АккаунтИмя);
			пСуществует			= Пользователь <> Неопределено;
						
			Поз					= СтрНайти(ADsPath, "DC=");
			Если Поз > 0 Тогда
				АккаунтДомен = Сред(ADsPath, Поз+3);
				Поз = СтрНайти(АккаунтДомен, ",");
				Если Поз >  0 Тогда
					АккаунтДомен = Лев(АккаунтДомен, Поз-1);
				КонецЕсли;			
			КонецЕсли;
			
			Если Не ПустаяСтрока(АккаунтИмя) Тогда
				
				НоваяСтрока					= ТаблицаПользователей.Добавить();
				НоваяСтрока.Логин			= АккаунтИмя;
				НоваяСтрока.Имя				= ?(ПустаяСтрока(Представление), АккаунтИмя, Представление);
				НоваяСтрока.Домен			= АккаунтДомен;				
				НоваяСтрока.Почта			= СтрПочта;
				НоваяСтрока.Телефон 		= СтрТелефон;
				НоваяСтрока.Существует		= пСуществует;
				НоваяСтрока.Подразделение 	= Подразделение;
				НоваяСтрока.Организация 	= Организация;
				НоваяСтрока.Должность	 	= Должность;
				НоваяСтрока.ADsPath			= ADsPath;								
				НоваяСтрока.ДатаРождения 	= УправлениеITОтделом8УФ.ПолучитьДатуИзСтроки(ДатаРождения);
				НоваяСтрока.Статус			= Статус;
				Если Пользователь <> Неопределено Тогда
					НоваяСтрока.ИдентификаторПользователяИБ = Пользователь;  
				КонецЕсли;
				
			КонецЕсли;
			
			Попытка				
				rs.MoveNext();
				Сч = Сч + 1;				
			Исключение				
				// делаем заглушку на ограничение MaxPageSize в политике ADSI.
				Прервать;				
			КонецПопытки;
			
		КонецЦикла;
	КонецЕсли;
	
	rs.Close();
	rs = Неопределено;
	
	conn.Close();
	conn = Неопределено;
	
	ТаблицаПользователей.Сортировать("Имя Возр");
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьВетвьВДеревоAD(conn, СтрокаДерева)
	
	CommandText = "<" + СтрокаДерева.Path + ">;(|(objectclass=organization)(objectclass=organizationalUnit)(objectclass=container));ADsPath, Name, distinguishedName;onelevel";
	cmd = Новый COMОбъект("ADODB.Command");
	cmd.ActiveConnection 				  = conn;
	cmd.Properties("Page Size").Value 	  = 100;
	cmd.Properties("Cache Results").Value = True;						
	cmd.CommandText 					  = CommandText;
	rs = cmd.Execute();
	
	Если rs.RecordCount > 0 Тогда 
		
		Пока Не rs.EOF Цикл
			
			НоваяСтрока 		= СтрокаДерева.ПолучитьЭлементы().Добавить(); 			
			НоваяСтрока.Path	= rs.Fields("ADsPath").Value;
			НоваяСтрока.Name	= rs.Fields("Name").Value;
			НоваяСтрока.LDAP	= rs.Fields("distinguishedName").Value; 
			
			ДобавитьВетвьВДеревоAD(conn, НоваяСтрока);
			
			Попытка
				rs.MoveNext();
			Исключение
				ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Превышен допустимый размер получаемых данных.'"));
				Прервать;
			КонецПопытки;
			
		КонецЦикла;
		
	КонецЕсли;
	
	rs.Close();
	rs = Неопределено;

КонецПроцедуры

&НаСервере
Процедура ЗаписатьОшибкуВЖурналРегистрации(Текст)

	ЗаписьЖурналаРегистрации("ActiveDirectory", УровеньЖурналаРегистрации.Ошибка, , , Текст);

КонецПроцедуры

&НаСервере
Процедура УстановитьНастройкиПодключения(ПрофильИмпортаИзAD)
	
	СЛС.УстановитьНастройкиПодключенияПоПрофилю(ПрофильИмпортаИзAD, ЭтаФорма);
		
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьНаКлиенте()
		
	Контексты.ПолучитьЭлементы().Очистить();
	
	Если ПодключениеИспользоватьУчетнуюЗапись Тогда	
		
		Попытка			
			
			Порт				= ?(ЗначениеЗаполнено(ПодключениеПорт), СокрЛП(ПодключениеПорт), "389");			
			КореньДерева		= ?(ЗначениеЗаполнено(ПодключениеКореньДерева), СокрЛП(ПодключениеКореньДерева), "");						
			СтрокаПодключения 	= "Provider=ADSDSOObject;User Id=" + ПодключениеДомен + "\" + ПодключениеУчетнаяЗапись + ";Password=" + ПодключениеПароль + ";";			
			conn				= Новый COMОбъект("ADODB.Connection");			
			conn.cursorLocation = 3;
			conn.Open(СтрокаПодключения);						
			
			Если ЗначениеЗаполнено(КореньДерева) Тогда 							
				LDAPText 	= "LDAP://" + ПодключениеКонтроллерДомена + ":" + Порт + "/" + КореньДерева;				
				CommandText	= "<" + СокрЛП(LDAPText) + ">;(objectClass=*);ADsPath, Name, distinguishedName;onelevel";				
			Иначе				
				LDAPText 	= "LDAP://" + ПодключениеКонтроллерДомена + ":" + Порт;
				CommandText = "<" + СокрЛП(LDAPText) + ">;(objectClass=domain);ADsPath, Name, distinguishedName;subtree";
			КонецЕсли;	
			
			cmd = Новый COMОбъект("ADODB.Command");
			cmd.ActiveConnection 				  = conn;
			cmd.Properties("Page Size").Value 	  = 100;
			cmd.Properties("Cache Results").Value = True;						
			cmd.CommandText 					  = CommandText;		
			rs = cmd.Execute();	
			
		Исключение			
			ОШ = ОписаниеОшибки();
			ОбщегоНазначенияКлиент.СообщитьПользователю(ОШ);
			Возврат;			
		КонецПопытки;
		
	Иначе		
		
		Попытка
			DSE				= ПолучитьCOMОбъект("LDAP://rootDSE"); 	// определяем домен, к которому принадлежит компьютер.
			LDAP_DNC		= DSE.Get("defaultNamingContext");     	// имя текущего домена.
			LDAPText		= "GC://" + LDAP_DNC; 					// используем глобальный каталог для поиска.
			// LDAPText 		= "LDAP://" + LDAP_DNC;
		Исключение
			ПоказатьПредупреждение(, НСтр("ru = 'Не найдены домены для импорта данных'"));
			Возврат;
		КонецПопытки;
		
		Попытка
			conn				= Новый COMОбъект("ADODB.Connection");;
			conn.Provider		= "ADSDSOObject";
			conn.cursorLocation = 3;
			conn.Open("ADs Provider");
		
			cmd = Новый COMОбъект("ADODB.Command");
			cmd.ActiveConnection = conn;
			cmd.Properties("Page Size").Value = 100;
			cmd.Properties("Cache Results").Value = True;						
			cmd.CommandText = "<" + LDAPText + ">;(objectClass=domain);ADsPath, Name, distinguishedName;subtree";		
			rs = cmd.Execute();			
		Исключение		
			ЗаписатьОшибкуВЖурналРегистрации(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Запрос к Active Directory не выполнен. Подробности в журнале регистрации...'"));
			Возврат;
		КонецПопытки;
		
	КонецЕсли;
	
	Если rs.RecordCount > 0 Тогда 
		Пока Не rs.EOF Цикл  
			
			НоваяСтрока			= Контексты.ПолучитьЭлементы().Добавить();
			НоваяСтрока.Name	= rs.Fields("Name").Value;
			НоваяСтрока.LDAP	= rs.Fields("distinguishedName").Value; 
			НоваяСтрока.Path	= rs.Fields("ADsPath").Value;  // берем путь "как есть", в т.ч. GC.
			
			ДобавитьВетвьВДеревоAD(conn, НоваяСтрока);
			
			Попытка
				rs.MoveNext();
			Исключение
				ЗаписатьОшибкуВЖурналРегистрации(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				ОбщегоНазначенияКлиент.СообщитьПользователю(НСтр("ru = 'Превышен допустимый размер получаемых данных.'"));
				Прервать;
			КонецПопытки;			
		КонецЦикла;
	КонецЕсли;
	
	rs.Close();
	rs = Неопределено;
	conn.Close();
	
КонецПроцедуры 

&НаКлиенте
Процедура УстановитьВсемДоменПочтыЗавершение(Значение, ДополнительныеПараметры) Экспорт
	
	стрДомен = ?(Значение = Неопределено, ДополнительныеПараметры.стрДомен, Значение);
	
	Для каждого Юзер Из ТаблицаПользователей Цикл		
		Если Юзер.Исправить Тогда
			Если ЗначениеЗаполнено(Юзер.Логин) Тогда
				Юзер.Почта = Юзер.Логин + "@" + стрДомен;
			Иначе	
				Юзер.Почта = Юзер.Имя + "@" + стрДомен;
			КонецЕсли;	
		КонецЕсли;	
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура УстановитьВсемПодразделениеЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Подразделение = Результат;	
	Для каждого Юзер Из ТаблицаПользователей Цикл
		Если Юзер.Исправить Тогда
			Юзер.Подразделение = Подразделение;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОтключитьПользователейСервер(ЕстьОшибки = Ложь)
	
	Для Каждого Стр Из ТаблицаПользователей Цикл
		Если Стр.Исправить 
			И ЗначениеЗаполнено(Стр.ИдентификаторПользователяИБ) Тогда
			
			ЕстьОшибкиВСтроке = Ложь;
			
			НачатьТранзакцию();
			
			Попытка				
				
				Пользователь1С = УправлениеITОтделом8УФ.НайтиПользователя1С(Стр.ИдентификаторПользователяИБ);
				Если ЗначениеЗаполнено(Пользователь1С) Тогда									
					ПользовательОбъект 		= Пользователь1С.ПолучитьОбъект(); 					
					// описание пользователя БД.
					ОписаниеПользователяИБ 	= Пользователи.НовоеОписаниеПользователяИБ();
					ОписаниеПользователяИБ.Вставить("Действие", "Удалить");					
					ПользовательОбъект.ДополнительныеСвойства.Вставить("ОписаниеПользователяИБ", ОписаниеПользователяИБ);					
					ПользовательОбъект.Недействителен = Истина;					
					ПользовательОбъект.Записать();					
				КонецЕсли;
				
			Исключение 
				
				ЕстьОшибкиВСтроке = Истина;
				ОбщегоНазначения.СообщитьПользователю( СтрШаблон(НСтр("ru = 'Ошибка при отключении пользователя %1: %2'"), Стр.Имя, ОписаниеОшибки()), СтатусСообщения.Важное);
				
			КонецПопытки;
			
			Если ЕстьОшибкиВСтроке 
				И Не ЕстьОшибки Тогда
				ЕстьОшибки = Истина;
			КонецЕсли;
			
			Если ЕстьОшибкиВСтроке Тогда
				ОтменитьТранзакцию();
			Иначе
				ЗафиксироватьТранзакцию();
				Стр.Исправить = Ложь;
				Стр.ИдентификаторПользователяИБ = ПользовательОбъект.ИдентификаторПользователяИБ;
			КонецЕсли;
			
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура КонтекстыПриАктивизацииСтрокиОбработчикОжидания()	
	
	ТекущиеДанные = Элементы.Контексты.ТекущиеДанные;	
	Если ТекущиеДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	СС 		= ПолучитьLDAPЗапросПоТекущемуЗначениюДереваAD(ТекущиеДанные.LDAP);		 
	ЗаполнитьТаблицуПользователей(СС, Элементы.ФормаВключатьПодчиненные.Пометка);
	
КонецПроцедуры

#КонецОбласти

