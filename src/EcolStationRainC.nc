/**
 Copyright (C),2014-2015, YTC, www.bjfulinux.cn
 Copyright (C),2014-2015, ENS Group, ens.bjfu.edu.cn
 Created on  2015-05-08 14:49
 
 @author: ytc recessburton@gmail.com
 @version: 1.0
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>
 **/

#include <Timer.h>
#include "EcolStationRain.h"
module EcolStationRainC{
	uses{
		interface Boot;
		interface SplitControl as RadioControl;
		interface StdControl as RoutingControl;
		interface Send;
		interface Leds;
		interface Receive;
		interface TelosbTimeSyncNodes as TimeSync;
		interface TelosbBuiltinSensors as Sensors;
		interface GpioInterrupt as GpInterrupt;
		interface EcolStationNeighbour;
		//LPL
		interface LowPowerListening;
	}
}
implementation{
	
	message_t packet;
	norace uint32_t inttime = 0;
	norace uint32_t id = 0;
	norace uint16_t temperature = 0;
	norace uint16_t humidity = 0;
	
	norace volatile bool sendBusy = FALSE;
	
	event void Boot.booted(){
		call TimeSync.Sync();
		call GpInterrupt.enableFallingEdge();	//下降沿中断使能(根据雨量筒特性，中断为下降沿)
		call RadioControl.start();
		call LowPowerListening.setLocalWakeupInterval(1024);
		call Sensors.readAllSensors();		//预读取（空读取），确保了第一次读取的成功
		call EcolStationNeighbour.startNei();
	}
	
	event void RadioControl.startDone(error_t err){
		if(err != SUCCESS){
			call RadioControl.start();
		}else{
			call RoutingControl.start();
		}
	}
	
	event void RadioControl.stopDone(error_t err){	
	}
	
	task void sendMessage(){
		CTPMsg* msg = (CTPMsg*)call Send.getPayload(&packet, sizeof(CTPMsg));

		msg -> datatype          = 0x02;	//0x01土壤湿度，0x02雨量筒中断. (后续可扩展)
		msg -> id                        = id;
		msg -> nodeid             = TOS_NODE_ID;
		msg -> data1                = temperature;
		msg -> data2                = humidity;
		msg -> eventtime       = inttime;
		
		if(call Send.send(&packet, sizeof(CTPMsg)) != SUCCESS)
			call Leds.led0On();
		else
			sendBusy = TRUE;	
	}
	
	task void startSense(){
		//单独调用获取每个传感器，缩短了时间
		call Sensors.readTemperature();
		call Sensors.readHumidity();
	}
	
	async event void GpInterrupt.fired(){
		call Leds.led2On();
		inttime = call TimeSync.getTime();		//获取时间放在第一个，提高记录触发时间的准确度
		id ++;			//只要触发中断，id就+1，即使后续数据包发送失败，也可以发现丢失
		post startSense();
		if( !sendBusy)
			post sendMessage();
	}
	
	event void Send.sendDone(message_t* m, error_t err){
		if(err != SUCCESS)
			call Leds.led0On();
		sendBusy = FALSE;	
		call Leds.led2Off();
	}
	
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
		return msg;	
	}
	

	event void TimeSync.SyncDone(uint32_t TimeOffset){
			call Leds.led1Toggle();
	}

	event void Sensors.readAllDone(error_t errT, uint16_t temp, error_t errH, uint16_t humi, error_t errL, uint16_t ligh, error_t errB, uint16_t batt){
	}

	event void Sensors.readHumidityDone(error_t err, uint16_t data){
		humidity = data;
	}

	event void Sensors.readTemperatureDone(error_t err, uint16_t data){
		temperature = data;
	}

	event void Sensors.readLightDone(error_t err, uint16_t data){
	}

	event void Sensors.readBatteryDone(error_t err, uint16_t data){
	}
}