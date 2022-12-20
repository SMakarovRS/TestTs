﻿
#Область СлужебныеПроцедурыИФункции

&НаКлиенте
// Процедра формирует идентификатор параметра расчетов.
//    
Процедура ПолучитьИдентификатор(СтрНаименование)
     
	Разделители     =  " .,+,-,/,*,?,=,<,>,(,)%!@#$%&*""№:;{}[]?()\|/`~'^_";
	 
	Объект.Идентификатор = "";
	БылСпецСимвол = Ложь;
	Для НомСимвола = 1 По СтрДлина(СтрНаименование) Цикл
	  	Символ = Сред(СтрНаименование,НомСимвола,1);
		Если СтрНайти(Разделители, Символ) <> 0 Тогда
		   БылСпецСимвол = Истина;
		ИначеЕсли БылСпецСимвол Тогда
		   БылСпецСимвол = Ложь;
		   Объект.Идентификатор = Объект.Идентификатор + ВРег(Символ);
		Иначе
		   Объект.Идентификатор = Объект.Идентификатор + Символ;          
		КонецЕсли;

	КонецЦикла;
          
КонецПроцедуры //ПолучитьИдентификатор

#КонецОбласти

#Область ОбработчикиСобытийРеквизитовФормы

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	
	ПолучитьИдентификатор(Объект.Наименование);
	
КонецПроцедуры // НаименованиеПриИзменении()

#КонецОбласти

