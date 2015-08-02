Author:YTC 
Mail:recessburton@gmail.com
Created Time: 2015.6.4

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

Description：
	Telosb 雨量筒中断采集程序，使用了CTP，与AD土壤湿度采集混合数据传输.
	注意，采用本程序的节点只做非根节点运行.
	
Logs：
	V2.0 加入了节点重启机制
	V1.9 链路质量评估包发送周期调整为555ms.采用最新时间同步组件，同步间隔调整为30s
	V1.8 更新邻居发现组件为0.6版本,调整链路质量计算方法
	V1.7 更新邻居发现组件为0.5版本
	V1.6 LPL设置成1s，（1024）
	V1.5 更新邻居发现组件为0.4版本
	V1.4 无线功率调只最大，payload增至35字节（通过makefile），加入LPL机制。
	V1.3 集成了EcolStationNeighour邻居建立接口，建立邻居关系，并CTP发送。
	V1.2 结合新版BS做了调整
	V1.1 调整CTPMsg格式，使更加普适化


BS version:
	BSCTPTest V2.2
	
Known Bugs: 
		none.

