﻿
#Область ОбработчикиСобытий

&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	Массив = Новый Массив;
	Массив.Добавить(ПараметрКоманды);
	
	СтруктураОтветственный = Новый Структура("Спринт", ПараметрКоманды);
	
	ОткрытьФорму("Отчет.СписокЗаданий.Форма",
		Новый Структура("КлючНазначенияИспользования, Отбор, СформироватьПриОткрытии", 
			Массив, СтруктураОтветственный, Истина),, 
		"ОтветственныйСотрудник=" + ПараметрКоманды, ПараметрыВыполненияКоманды.Окно);
		
КонецПроцедуры
	
#КонецОбласти