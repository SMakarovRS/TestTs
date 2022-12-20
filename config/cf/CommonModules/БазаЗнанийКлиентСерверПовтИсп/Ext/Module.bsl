﻿////////////////////////////////////////////////////////////////////////////////
// Модуль повторного использования базы знаний.
//  
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// ВЕРСТКА СТРАНИЦ ИНТЕРФЕЙСА

Функция ТекстHTML_Выравнивание(Знач Выравнивание) Экспорт
	
	// -- Выравнивание
	// 0 - по левому краю
	// 1 - по правому краю
	// 2 - по центру
	
	Если Выравнивание = 0 Тогда
		Обтекание	= "left";
		Отступы		= "margin: 0 10px 10px 0;"
	ИначеЕсли Выравнивание = 1 Тогда
		Обтекание	= "right";
		Отступы		= "margin: 0 0 10px 10px;"
	Иначе 
		Обтекание	= "none";
		Отступы		= "";
	КонецЕсли;
	
	Возврат "float:" + Обтекание + ";" + Отступы;
	
КонецФункции

//@skip-warning
Функция МодульВерсткиСтраницПортала() Экспорт
	
КонецФункции	

////////////////////////////////////////////////////////////////////////////////
// ОБЩИЕ МЕТОДЫ

Функция ПолучитьДопустимыеСимволыИмени() Экспорт
	
	Возврат "абвгдежзийклмнопрстуфхцчшщъыьэюя" + 
		"0123456789" + 
		"abcdefghijklmnopqrstuvwxyz" +
		"_";
	
КонецФункции

Функция ПолучитьАдресВременногоХранилища(Идентификатор, Имя) Экспорт
	
	Возврат "";
	
КонецФункции

//@skip-warning
Функция ЕстьИнтернетСоединение() Экспорт
	
	Возврат Ложь; //Истина;
	
	#Если Сервер ИЛИ ВнешнееСоединение Тогда
		Возврат Ложь;
	#Иначе
		Результат = ПолучениеФайловИзИнтернетаКлиент.СкачатьФайлНаКлиенте("http://code.jquery.com/jquery-latest.min.js");
		Если Результат.Статус Тогда
			Возврат Истина;
		Иначе 
			Возврат Ложь;
		КонецЕсли;
	#КонецЕсли
	
КонецФункции

Функция ТекущийПользователь() Экспорт
	
	Возврат БазаЗнанийВызовСервера.ТекущийПользователь();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// МЕТОДЫ РАБОТЫ С НАСТРОЙКАМИ БАЗЫ ЗНАНИЙ

Функция ПолучитьСтруктуруОбщихНастроекБазыЗнаний() Экспорт
	
	НастройкаАдминистратор = Новый Структура("Представление, ИмяРесурса, Типы",
		"Администратор",
		"ЗначениеСсылка",
		Новый ОписаниеТипов("СправочникСсылка.Пользователи"));
		
	НастройкаАдресПортала = Новый Структура("Представление, ИмяРесурса, Типы",
		"Адрес MediaWiki",
		"ЗначениеСтрока",
		Неопределено);
	
	НастройкаWebКаталог = Новый Структура("Представление, ИмяРесурса, Типы",
		"Web-каталог",
		"ЗначениеСтрока",
		Неопределено);
	
	НастройкаЛокальныйКаталог = Новый Структура("Представление, ИмяРесурса, Типы",
		"Локальный каталог",
		"ЗначениеСтрока",
		Неопределено);
	
	Настройки = Новый Структура;
	Настройки.Вставить("Администратор"		, Новый ФиксированнаяСтруктура(НастройкаАдминистратор));
	Настройки.Вставить("АдресMediaWiki"		, Новый ФиксированнаяСтруктура(НастройкаАдресПортала));
	Настройки.Вставить("WebКаталог"			, Новый ФиксированнаяСтруктура(НастройкаWebКаталог));
	Настройки.Вставить("ЛокальныйКаталог"	, Новый ФиксированнаяСтруктура(НастройкаЛокальныйКаталог));
	
	Возврат Новый ФиксированнаяСтруктура(Настройки);
	
КонецФункции

Функция ПолучитьЗначениеОбщейНастройки(ИмяНастройки) Экспорт 
	
	Возврат БазаЗнанийВызовСервера.ПолучитьЗначениеНастройки(ИмяНастройки);
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// МЕТОДЫ РАБОТЫ С ФАЙЛАМИ БАЗЫ ЗНАНИЙ

&НаКлиенте
Функция Скрипты() Экспорт
	
	МассивСкриптов = Новый Массив;
	
	МассивСкриптов.Добавить(Новый Структура("Макет, АдресURL",
		"jquery_1_11_0",
		"http://code.jquery.com/jquery-latest.min.js"));
	МассивСкриптов.Добавить(Новый Структура("Макет, АдресURL",
		"kdb_script",
		"http://www.progtb.ru/files/confkdb/scripts/kdb_script.js"));
	
	Возврат МассивСкриптов;
	
КонецФункции

#КонецОбласти