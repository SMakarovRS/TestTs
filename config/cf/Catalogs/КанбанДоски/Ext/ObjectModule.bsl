﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ЭтоГруппа Тогда
		
		Если НЕ ЗначениеЗаполнено(ТипФона) Тогда
			ТипФона = Перечисления.ТипФонаКанбанДоски.ЦветФона;
		КонецЕсли;
				
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли