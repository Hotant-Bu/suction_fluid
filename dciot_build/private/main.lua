------------------------------------
-- 提示
-- 如果使用其他Lua编辑工具编辑此文档，请将VisualTFT软件中打开的此文件编辑器视图关闭，
-- 因为VisualTFT具有自动保存功能，其他软件修改时不能同步到VisualTFT编辑视图，
-- VisualTFT定时保存时，其他软件修改的内容将被恢复。
--
-- Attention
-- If you use other Lua Editor to edit this file, please close the file editor view 
-- opened in the VisualTFT, Because VisualTFT has an automatic save function, 
-- other Lua Editor cannot be synchronized to the VisualTFT edit view when it is modified.
-- When VisualTFT saves regularly, the content modified by other Lua Editor will be restored.
------------------------------------

--下面列出了常用的回调函数
--更多功能请阅读<<LUA脚本API.pdf>>


-- local absorb_liquid = 0
local sc_id_0 = 0
-- 回原点标志位
local zero_is = 0;
-- local absorb_liquid_wait_time_s = 0;
local count_i = 0;

function on_timer(timer_id)
	if timer_id == 0 then
		print("stop_timer......");

		-- 上下夹爪同时打开-上夹爪打开
		local top_cmd_register_value = {};
		top_cmd_register_value[0] = 0;
		top_cmd_register_value[1] = 64000;
		-- 写多个寄存器
		mb_write_reg_16(64,10314,top_cmd_register_value);

		-- 上下夹爪同时打开-下夹爪打开
		local top_cmd_register_value = {};
		top_cmd_register_value[0] = 0;
		top_cmd_register_value[1] = 64000;
		-- 写多个寄存器
		mb_write_reg_16(64,10414,top_cmd_register_value);

		stop_timer(0);
		-- 开启另外一个计时器
		-- start_timer(1,7000,0,0);

	elseif timer_id == 1 then
		-- 上夹爪上移吸液
		local cmd_register_value = {};
		-- FF FF 06 00
		-- cmd_register_value[0] = 0x0003;
		-- cmd_register_value[1] = 0xE800;
		cmd_register_value[0] = 0x0000;
		cmd_register_value[1] = 0xFA00;
		print("clamp jaw move up mb_write_reg_16 will run......");
		mb_write_reg_16(64,10214,cmd_register_value);

		stop_timer(1);
		-- start_timer(2,2330,0,0);
		-- start_timer(2,5000,0,0);
		start_timer(2,300,0,0);
	elseif timer_id == 2 then

		-- 读取当前位置，运动到位即停止
		-- local current_position = mb_read_reg_03(64,12014,2);
		-- local current_position = mb_read_reg_03(64,10202,2);
		local current_position = mb_read_reg_03(64,10200,6);

		-- local current_postion = current_position(64,10200);
		-- local current_postion = current_position(64,10202);
		-- set_text(4,6,current_position[3]);
		-- set_text(4,8,current_position[4]);
		if current_position[3] == 64000 then

			-- 先要不断读取上夹爪上移吸液是否运行到位，如果到位了立刻停止计时器2
			stop_timer(2);
			-- 一次吸液完成，ch1下降前设置下降速度
			local running_speed_cmd_register_value={};
			-- running_speed_cmd_register_value[0]=1;
			-- running_speed_cmd_register_value[1]=30464;
			running_speed_cmd_register_value[0]=0x0000;
			running_speed_cmd_register_value[1]=0x7D00;
			-- 写入多个寄存器
			mb_write_reg_16(64,12370,running_speed_cmd_register_value);

			-- 获取吸完液停留等待时间
			local absorb_liquid_wait_time_s = get_variant("absorb_liquid_wait_time");
			print("absorb_liquid_wait_time_s: ",absorb_liquid_wait_time_s);
			-- set_text(4,11,absorb_liquid_wait_time_s);
			if absorb_liquid_wait_time_s > 0 then
				start_timer(5,absorb_liquid_wait_time_s,0,0);
			else
				-- 最后停留10（默认值）
				start_timer(5,5000,0,0);
			end

		end


	elseif timer_id == 5 then
		-- 停留指定秒数过后，上夹爪先向下移动一小段距离再打开
		stop_timer(5);
		-- 上夹爪向下移动一小段距离
		-- local cmd_register_value = {};
		-- -- FF FF 06 00
		-- cmd_register_value[0] = 0xFFFF;
		-- -- cmd_register_value[1] = 0xD8F0;
		-- -- cmd_register_value[1] = 0x0600;
		-- cmd_register_value[1] = 0x8300;
		-- print("clamp jaw move up mb_write_reg_16 will run......");
		-- mb_write_reg_16(64,10214,cmd_register_value);

		-- ch1上下移动回原点
		goto_zero(64,10210);

		-- 同时上下夹爪打开
		-- 先打开上夹爪
		-- 上下夹爪同时打开-上夹爪打开
		local top_cmd_register_value = {};
		top_cmd_register_value[0] = 0;
		top_cmd_register_value[1] = 64000;
		-- 写多个寄存器
		mb_write_reg_16(64,10314,top_cmd_register_value);
		mb_write_reg_16(64,10414,top_cmd_register_value);


		-- 整个吸液完成，重新开启监测开始吸液信号

		-- 如果开始吸液信号一直处于开始状态，此时吸液完毕，则说明
		-- 吸液器并没有拿走，此情况下，不能再进行下一次的吸液动作了，
		-- 需要持续检测吸液器是否拿走，拿走了才可以进行下一次吸液操作
		start_timer(13,500,0,0);
		
		-- start_timer(6,2000,0,0);
		-- start_timer(7,3000,0,0);
	-- elseif timer_id == 6 then
	-- 	stop_timer(6);
	-- 	-- 先打开上夹爪
	-- 	-- 上下夹爪同时打开-上夹爪打开
	-- 	local top_cmd_register_value = {};
	-- 	top_cmd_register_value[0] = 0;
	-- 	top_cmd_register_value[1] = 64000;
	-- 	-- 写多个寄存器
	-- 	mb_write_reg_16(64,10314,top_cmd_register_value);

	-- 	-- 上下夹爪同时打开-下夹爪打开
	-- 	-- local bottom_cmd_register_value = {};
	-- 	-- bottom_cmd_register_value[0] = 0;
	-- 	-- bottom_cmd_register_value[1] = 64000;
	-- 	-- 写多个寄存器
	-- 	mb_write_reg_16(64,10414,top_cmd_register_value);
		
	-- 	start_timer(7,3000,0,0);

	-- elseif timer_id == 7 then
	-- 	-- 上夹爪下移动（回原点）
	-- 	stop_timer(7);

	-- 	-- ch1上下移动回原点
	-- 	goto_zero(64,10210);

	-- 	-- 每次完成吸液后需要恢复上下夹爪及上夹爪上下移动的速度，放这里不对，暂时关闭
	-- 	-- local is_zero = is_on_zero(64,12006);
	-- 	-- if is_zero == "1" then
	-- 	-- 	-- 一次吸液完成后恢复上下夹爪及上夹爪上下移动的速度
	-- 	-- 	local running_speed_cmd_register_value={};
	-- 	-- 	running_speed_cmd_register_value[0]=0;
	-- 	-- 	running_speed_cmd_register_value[1]=32000;
	-- 	-- 	-- 写入多个寄存器
	-- 	-- 	mb_write_reg_16(64,12370,running_speed_cmd_register_value);
	-- 	-- 	mb_write_reg_16(64,12380,running_speed_cmd_register_value);
	-- 	-- 	mb_write_reg_16(64,12390,running_speed_cmd_register_value);
	-- 	-- end


	-- 	-- 整个吸液完成，重新开启监测开始吸液信号

	-- 	-- 如果开始吸液信号一直处于开始状态，此时吸液完毕，则说明
	-- 	-- 吸液器并没有拿走，此情况下，不能再进行下一次的吸液动作了，
	-- 	-- 需要持续检测吸液器是否拿走，拿走了才可以进行下一次吸液操作
	-- 	start_timer(13,500,0,0);

	elseif timer_id == 9 then
		-- count_i = count_i+1;
		-- print("set_text count_i is: ",count_i);
		-- set_text(4,9,count_i);

		-- 读取状态位

		local is_zero = is_on_zero(64,12012);
		if is_zero == "1" then
			-- set_text(4,10,is_zero);
			-- 如果状态为1，则运行到了原点。此时停止计数器
			stop_timer(9);
		end

		-- if is_zero == "0" then
		-- 	set_text(4,11,is_zero);
		-- end

	elseif timer_id == 10 then
		-- 读取状态位

		local is_zero = is_on_zero(64,12018);
		if is_zero == "1" then
			-- 如果状态为1，则运行到了原点。此时停止计数器
			stop_timer(10);
		end
	elseif timer_id == 11 then
		-- 读取状态位

		local is_zero = is_on_zero(64,12006);
		if is_zero == "1" then
			-- 如果状态为1，则运行到了原点。此时停止计数器
			stop_timer(11);
		end
	elseif timer_id == 8 then
		-- ch0读取状态位
		local is_zero = is_on_zero(64,12000);
		if is_zero == "1" then
			-- 如果状态为1，则运行到了原点。此时停止计数器
			stop_timer(8);
		end
		

	elseif timer_id == 12 then
		local enable_absorb_liquid = enable_start_absorb_liquid_singnal(64);
		-- 返回1则吸液
		if enable_absorb_liquid == "1" then
			-- 吸液动作运行时则关闭检测是否吸液定时器，运行完后再开启
			stop_timer(12);

			-- 设置吸液过程中上下夹爪张开/闭合的速度
			-- local top_bottom_clamp_speed = get_variant("absorb_liquid_top_bottom_clamp_speed");
			
			-- 开始吸液，先设置吸液夹爪--上夹爪上移的速度
			local running_speed_cmd_register_value={};
			running_speed_cmd_register_value[0]=0;
			running_speed_cmd_register_value[1]=32000;
			-- 写入多个寄存器
			mb_write_reg_16(64,12370,running_speed_cmd_register_value);


			local clamp_jaw_open_close_running_speed_cmd_register_value={};
			clamp_jaw_open_close_running_speed_cmd_register_value[0]=0x0001;
			clamp_jaw_open_close_running_speed_cmd_register_value[1]=0xF400;
			mb_write_reg_16(64,12380,clamp_jaw_open_close_running_speed_cmd_register_value);
			mb_write_reg_16(64,12390,clamp_jaw_open_close_running_speed_cmd_register_value);

			-- 检测到开始吸液信号，在开始吸液之前延时等待一会儿
			local start_absorb_liquid_wait_time = get_variant("start_absorb_liquid_wait");
			if start_absorb_liquid_wait_time > 0 then
				-- set_text(4,12,start_absorb_liquid_wait_time);
				start_timer(14,start_absorb_liquid_wait_time,0,0);
			else
				-- set_text(4,12,5);
				start_timer(14,5,0,0);
			end

		end

	elseif timer_id == 13 then
		local enable_absorb_liquid_continue = enable_start_absorb_liquid_singnal(64);
		-- 返回1则吸液
		if enable_absorb_liquid_continue == "0" then
			stop_timer(13);
			start_timer(12,500,0,0);
		end

	elseif timer_id == 14 then
		stop_timer(14);

		-- 开始吸液
		-- ch2上夹爪回原点
		goto_zero(64,10310);

		-- os.execute("sleep 5");

		-- ch3下夹爪回原点
		goto_zero(64,10410);

		start_timer(1,600,0,0);

	elseif timer_id == 15 then
		-- 读取DI7信号
		local bit7 = jog_switch_status_bit7(64);
		-- 读取DI6信号
		local bit6 = jog_switch_status_bit6(64);

		if bit7 == "1" then
			if bit6 == "0" or bit6 == nil then
				local ch0_jog_register_value = {};
				ch0_jog_register_value[0] = 0;
				ch0_jog_register_value[1] = 32000;
				mb_write_reg_16(64,12520,ch0_jog_register_value);
			end

		elseif bit6 == "1" then
			if bit7 == "0" or bit7 == nil then
				local ch0_jog_register_value = {};
				ch0_jog_register_value[0] = 0xFFFF;
				ch0_jog_register_value[1] = 0x8300;
				mb_write_reg_16(64,12520,ch0_jog_register_value);
			end
		else
			-- 停止大臂向下运行
			local ch0_jog_register_value = {};
			ch0_jog_register_value[0] = 0;
			ch0_jog_register_value[1] = 0;
			mb_write_reg_16(64,12520,ch0_jog_register_value);

		end

	-- elseif timer_id == 16 then
	-- 	-- -- 电机使能
	-- 	-- mb_write_reg_06(10,0,1);
	-- 	-- set_text(4,9,"使能");

	-- 	count_i = count_i + 1;

	-- 	-- 读取当前机器状态
	-- 	local status = mb_read_reg_03(10,16,1);

	-- 	if status[0] == 0 then
	-- 		set_text(4,12,count_i);
	-- 		-- 发送指令开始磁搅
	-- 		local res = mb_write_reg_06(10,2,500);
	-- 		if res then
	-- 			-- set_text(4,6,"停止磁搅拌");
	-- 			set_text(4,10,status[0]);

	-- 			stop_timer(16);
	-- 		else
	-- 			set_text(4,6,"开始失败");
	-- 		end
			
	-- 	elseif status[0] > 0  or status == nil then
	-- 		set_text(4,14,count_i);
	-- 		-- 发送指令
	-- 		local res = mb_write_reg_06(10,2,0);
	-- 		if res then
	-- 			-- set_text(4,6,"开始磁搅拌");
	-- 			set_text(4,11,"已停止");
	-- 			stop_timer(16);
	-- 		else
	-- 			set_text(4,6,"停止失败");
	-- 		end

	-- 	end

	end
end

--初始化函数
function on_init()
	print("dacai start...");
	print("set some speed argument......");
	ch0_set_speed();
	ch1_set_speed();
	ch2_set_speed();
	ch3_set_speed();

	-- 电机使能
	mb_write_reg_06(10,0,1);
	-- local enable_res = mb_write_reg_06(10,0,1);
	-- if enable_res then
	-- 	set_text(4,9,"使能");
	-- else
	-- 	set_text(4,9,"不能");
	-- end


	-- 检测是否吸液信号定时器
	start_timer(12,500,0,0);
	-- 监听大臂上下按钮信号，Bit6（上），Bit7（下）
	start_timer(15,300,0,0);


end

--定时回调函数，系统每隔1秒钟自动调用。
--function on_systick()
--end

--定时器超时回调函数，当设置的定时器超时时，执行此回调函数，timer_id为对应的定时器ID
--function on_timer(timer_id)
--end

--用户通过触摸修改控件后，执行此回调函数。
--点击按钮控件，修改文本控件、修改滑动条都会触发此事件。
function on_control_notify(screen,control,value)
	if screen == 4 then

		if control == 19 then
			-- 获取设置的吸液完成停留时间
			local absorb_liquid_wait_txt = get_value(4,19);
			local absorb_liquid_wait = tonumber(absorb_liquid_wait_txt);
			print("absorb_liquid_wait: ", absorb_liquid_wait);

			-- local absorb_liquid_wait_time_s = (absorb_liquid_wait + 2.33)*1000;
			local absorb_liquid_wait_time_s = absorb_liquid_wait*1000;
			-- 设置内存变量 absorb_liquid_wait_time
			set_variant("absorb_liquid_wait_time",absorb_liquid_wait_time_s);
			local absorb_liquid_wait_time_s_get = get_variant("absorb_liquid_wait_time");

			-- absorb_liquid_wait_time_s = real_wait_time;
			print("absorb_liquid_wait_time_s: ",absorb_liquid_wait_time_s_get);

		end

		if control == 22 then
			-- 获取开始吸液前设置的延时时间
			local start_absorb_liquid_wait = get_value(4,22);
			local start_absorb_liquid_wait_int = tonumber(start_absorb_liquid_wait);
			local start_absorb_liquid_wait_ms = start_absorb_liquid_wait_int*1000
			-- 设置内存变量
			set_variant("start_absorb_liquid_wait",start_absorb_liquid_wait_ms);
		end

		-- if control == 24 then

		-- 	local absorb_liquid_top_bottom_clamp_speed_input = get_value(4,24);
		-- 	local absorb_liquid_top_bottom_clamp_speed_int = tonumber(absorb_liquid_top_bottom_clamp_speed_input);
		-- 	set_variant("absorb_liquid_top_bottom_clamp_speed",absorb_liquid_top_bottom_clamp_speed_int);

		-- 	local running_speed_cmd_register_value={};
		-- 	running_speed_cmd_register_value[0]=1;
		-- 	running_speed_cmd_register_value[1]=30464;
		-- 	-- 写入多个寄存器
		-- 	mb_write_reg_16(64,12370,running_speed_cmd_register_value);
		-- 	mb_write_reg_16(64,12380,running_speed_cmd_register_value);
		-- 	mb_write_reg_16(64,12390,running_speed_cmd_register_value);

		-- 	-- ch1_absorb_liquid_running_speed(running_speed);
		-- 	-- ch2_absorb_liquid_running_speed(running_speed);
		-- 	-- ch3_absorb_liquid_running_speed(running_speed);

		-- end

		-- if control == 6 then
		-- 	--[获取变量值]
		-- 	-- local temperature = get_variant("temperature_txt")
		-- 	-- 获取页面ID=0，控件ID=1的值
		-- 	local temperature = get_value(4,6)

		-- 	print("temperature value is: ",temperature);
		-- 	-- 设置变量值
		-- 	-- set_variant("absorb_liquid",temperature);

		-- 	-- 设置变量值
		-- 	set_variant("temperature_txt",temperature);

		-- 	local temperature_txt_value = get_variant("temperature_txt");
		-- 	print("temperature_txt value is: ", temperature_txt_value);


		-- 	-- 设置控件值
		-- 	-- set_value(sc_id_0,3,temperature)
		-- end


		print("handle home page......");

		-- 开始吸液之前初始化设备
		if control == 5 then
			print("start absorb liquid......");
			-- 开始吸液体之前
			-- 初始化设备
			-- 1、检测上/下夹爪是否张开，未张开，则张开
			-- 2、当上/下夹爪都处于张开状态，则进行ch1归零操作
			-- 3、上/下夹爪同时闭合（归零）
			-- 4、上夹爪上移（前进）开始吸液
			-- 5、上夹爪上移完成吸液行程后，上夹爪张开，然后下夹爪张开

			ch0_set_speed();
			ch1_set_speed();
			ch2_set_speed();
			ch3_set_speed();


			-- 初始化设备，回原点

			-- ch1上下移动回原点
			ch1_goto_zero();

			-- ch2上夹爪回原点
			ch2_goto_zero();
			-- count_i = 0;
			-- local res = int_to_bin16_str(609);
			-- print("res: ",res);

			-- ch3下夹爪回原点
			ch3_goto_zero();

			start_timer(0,7000,0,0);
			

			-- continous_get_current_position();


		-- elseif control == 8 then
		-- 	print("start absorb liquid......");

		-- 	-- ch2上夹爪回原点
		-- 	goto_zero(64,10310);

		-- 	-- os.execute("sleep 5");

		-- 	-- ch3下夹爪回原点
		-- 	goto_zero(64,10410);

			-- start_timer(1,3000,0,0);

		-- -- 监听磁搅拌是否开启/关闭
		-- elseif control == 6 then
		-- 	-- start_timer(16,50,0,0);

		-- elseif control == 6 then
		-- 	mb_write_reg_06(10,2,1500);

		end




	elseif screen == 0 then
		print("handle page ch0......");
		if control == 5 then
			-- 如：要写入的两个寄存器的值为00 00 FA 00，
			-- 数组下面字（word）数组中每个元素对应一个寄存器要写入的值，
			-- 即：00 00转换为：0（十进制），FA 00转换为：64000（十进制）
			local cmd_register_value = {};
			cmd_register_value[0] = 0;
			cmd_register_value[1] = 64000;
			print("clamp jaw move down mb_write_reg_16 will run......");
			-- 写多个寄存器
			mb_write_reg_16(64,10114,cmd_register_value);

		elseif control == 6 then
			local cmd_register_value = {};
			-- FF FF 06 00
			cmd_register_value[0] = 65535;
			cmd_register_value[1] = 1536;
			print("clamp jaw move up mb_write_reg_16 will run......");
			mb_write_reg_16(64,10114,cmd_register_value);
		end

	

	end

end

--当画面切换时，执行此回调函数，screen为目标画面。
--function on_screen_change(screen)
--end

--[将返回结果转换为带空格分割的16进制字符串]
local function bytes_to_hex_spaced(bytes)
	local hex_chars = {};
	for _, b in ipairs(bytes) do
		table.insert(hex_chars, string.format("%02x",b));
	end
	print("hex_chars: ", hex_chars);
	return table.concat(hex_chars, " ");
end

--[整数转换为16位二进制字符串]
function int_to_bin16_str(n)
	print("int_to_bin16_str input args: ",n);

	local bits = {};
	for i = 15,0,-1 do
		if n>= (2^i) then
			bits[#bits + 1] = "1";
			n = n - (2^i);
		else
			bits[#bits + 1] = "0";
		end
	end
	return table.concat(bits);

end

-- 电机停止运动
-- slave，从机地址；addr，寄存器地址
function stop_motor_move(slave,addr)
	local cmd_register_value = {};
	cmd_register_value[0] = 0;
	cmd_register_value[1] = 0;
	mb_write_reg_16(slave,addr,cmd_register_value);
end

-- 是否在原点。1为已经移动至原点位置
function is_on_zero(slave,addr)
	-- 读取状态位
	local status = mb_read_reg_03(slave,addr,6);
	-- set_text(4,12,status[0]);
	-- set_text(4,13,status[1]);
	-- set_text(4,14,status[2]);

	-- 获取保存状态位数据的寄存器
	local two_reg_low_bit_str = int_to_bin16_str(status[1]);
	-- set_text(4,15,two_reg_low_bit_str);
	-- 回原点标志，1 为回原点执行中，0 为无运行或已完成
	local is_zero_position_bit = string.sub(two_reg_low_bit_str,10,10);
	-- 原点标志位，1为已经移动至原点位置
	-- local is_zero_position_bit = string.sub(two_reg_low_bit_str,7,7);
	
	return is_zero_position_bit;
end
-- 金属开关，控制大臂点动
function jog_switch_status_bit6(slave)
	-- 读取状态位
	local status = mb_read_reg_03(slave,1000,1);
	-- set_text(4,13,status[0]);
	local two_reg_low_bit_str = int_to_bin16_str(status[0]);
	-- set_text(4,15,two_reg_low_bit_str);
	-- 获取Bit6标识
	local bit6 = string.sub(two_reg_low_bit_str,10,10);
	return bit6;
end
-- 金属开关，控制大臂点动
function jog_switch_status_bit7(slave)
	-- 读取状态位
	local status = mb_read_reg_03(slave,1000,1);
	-- set_text(4,13,status[0]);
	local two_reg_low_bit_str = int_to_bin16_str(status[0]);
	-- set_text(4,15,two_reg_low_bit_str);
	-- 获取Bit6标识
	local bit7 = string.sub(two_reg_low_bit_str,9,9);
	return bit7;
end

-- 移动方向，方向标志，1 为后退，0 为前进
function current_move_direction()
	-- 读取状态位
	local status = mb_read_reg_03(slave,addr,6);

	-- 获取保存状态位数据的寄存器
	local two_reg_low_bit_str = int_to_bin16_str(status[1]);

	-- 移动方向，方向标志，1 为后退，0 为前进
	local move_direction_bit = string.sub(two_reg_low_bit_str,11,11);

	return move_direction_bit;
end

-- 获取当前位置，直接返回整数值
function current_position(slave,addr)
	-- 读取状态位
	local status = mb_read_reg_03(slave,addr,6);
	-- 当前位置
	local current_position = status[3];
	return current_position;
end


-- 移动指定距离
function move_distance(slave,addr,reg_value_int)
	local cmd_register_value = {};
	-- cmd_register_value为整数，要转为word数组。65535
	if reg_value_int <= 0xFFFF then
		-- 转换为4位16进制
		local cmd_reg_value_str = string.format("%04x",reg_value_int);
		-- 切割高低位
		local high_hex_str = string.sub(cmd_reg_value_str,1,2);
		local low_hex_str = string.sub(cmd_reg_value_str,3,4);
		-- 转为整数
		local high_int = tonumber(high_hex_str,16);
		local low_int = tonumber(low_hex_str,16);
		cmd_register_value[0] = high_int;
		cmd_register_value[1] = low_int;

	elseif reg_value_int > 0xFFFF then
		-- 转换为4位16进制
		local cmd_reg_value_str = string.format("%04x",reg_value_int);
		-- 切割高低位
		local high_high_hex_str = string.sub(cmd_reg_value_str,1,2);
		local high_low_hex_str = string.sub(cmd_reg_value_str,3,4);
		local low_high_hex_str = string.sub(cmd_reg_value_str,5,6);
		local low_low_hex_str = string.sub(cmd_reg_value_str,7,8);

		local high_high_hex_int = tonumber(high_high_hex_str,16);
		local high_low_hex_int = tonumber(high_low_hex_str,16);
		local low_high_hex_int = tonumber(low_high_hex_str,16);
		local low_low_hex_int = tonumber(low_low_hex_str,16);

		-- 放入数据寄存器中
		cmd_register_value[0]= high_high_hex_int;
		cmd_register_value[1]= high_low_hex_int;
		cmd_register_value[2]= low_high_hex_int;
		cmd_register_value[3]= low_low_hex_int;
	else
		cmd_register_value[0] = 0;
		cmd_register_value[1] = 0;
	end

	-- 写入多个寄存器
	mb_write_reg_16(slave,addr,cmd_register_value);
end

function ch0_set_speed()
	-- ch0 设置运行速度
	local running_speed_cmd_register_value={}
	running_speed_cmd_register_value[0]=0x0000;
	running_speed_cmd_register_value[1]=0x7d00;
	-- 写入多个寄存器
	mb_write_reg_16(64,12360,running_speed_cmd_register_value);
	-- 起始速度
	local start_speed_cmd_register_value={}
	start_speed_cmd_register_value[0]=0x0000;
	start_speed_cmd_register_value[1]=0x0C80;
	-- 写入多个寄存器
	mb_write_reg_16(64,12362,start_speed_cmd_register_value);

	-- 加速时间
	local accumulate_time_cmd_register_value={}
	accumulate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12364,accumulate_time_cmd_register_value);

	-- 减速时间
	local decelerate_time_cmd_register_value={}
	decelerate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12365,decelerate_time_cmd_register_value);

	-- 停止速度
	local stop_speed_cmd_register_value={}
	stop_speed_cmd_register_value[0]=0x0000;
	stop_speed_cmd_register_value[1]=0x0640;
	-- 写入多个寄存器
	mb_write_reg_16(64,12366,stop_speed_cmd_register_value);

end

function ch1_set_speed()
	-- ch1 设置运行速度
	local running_speed_cmd_register_value={}
	running_speed_cmd_register_value[0]=0x0000;
	running_speed_cmd_register_value[1]=0x7d00;
	-- running_speed_cmd_register_value[1]=0xFA00;
	-- running_speed_cmd_register_value[1]=32000;
	-- 写入多个寄存器
	mb_write_reg_16(64,12370,running_speed_cmd_register_value);
	-- 起始速度
	local start_speed_cmd_register_value={}
	start_speed_cmd_register_value[0]=0x0000;
	start_speed_cmd_register_value[1]=0x0C80;
	-- 写入多个寄存器
	mb_write_reg_16(64,12372,start_speed_cmd_register_value);

	-- 加速时间
	local accumulate_time_cmd_register_value={}
	accumulate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12374,accumulate_time_cmd_register_value);

	-- 减速时间
	local decelerate_time_cmd_register_value={}
	decelerate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12375,decelerate_time_cmd_register_value);

	-- 停止速度
	local stop_speed_cmd_register_value={}
	stop_speed_cmd_register_value[0]=0x0000;
	stop_speed_cmd_register_value[1]=0x0640;
	-- 写入多个寄存器
	mb_write_reg_16(64,12376,stop_speed_cmd_register_value);

end
function ch2_set_speed()
	-- ch2 设置运行速度
	local running_speed_cmd_register_value={}
	running_speed_cmd_register_value[0]=0x0000;
	running_speed_cmd_register_value[1]=0x7d00;
	-- 写入多个寄存器
	mb_write_reg_16(64,12380,running_speed_cmd_register_value);
	-- 起始速度
	local start_speed_cmd_register_value={}
	start_speed_cmd_register_value[0]=0x0000;
	start_speed_cmd_register_value[1]=0x0C80;
	-- 写入多个寄存器
	mb_write_reg_16(64,12382,start_speed_cmd_register_value);

	-- 加速时间
	local accumulate_time_cmd_register_value={}
	accumulate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12384,accumulate_time_cmd_register_value);

	-- 减速时间
	local decelerate_time_cmd_register_value={}
	decelerate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12385,decelerate_time_cmd_register_value);

	-- 停止速度
	local stop_speed_cmd_register_value={}
	stop_speed_cmd_register_value[0]=0x0000;
	stop_speed_cmd_register_value[1]=0x0640;
	-- 写入多个寄存器
	mb_write_reg_16(64,12386,stop_speed_cmd_register_value);

end


function ch1_absorb_liquid_running_speed(running_speed)
	local running_speed_cmd_register_value={};
	local running_speed_16 = string.format("%08x",running_speed);
	-- 拆解出高四位
	local high_running_speed_16 = string.sub(running_speed_16,1,4);
	-- 拆解出低四位
	local low_running_speed_16 = string.sub(running_speed_16,5,8);

	running_speed_cmd_register_value[0]=tonumber(high_running_speed_16,16);
	running_speed_cmd_register_value[1]=tonumber(low_running_speed_16,16);
	-- 写入多个寄存器
	mb_write_reg_16(64,12370,running_speed_cmd_register_value);
end
function ch2_absorb_liquid_running_speed(running_speed)
	local running_speed_cmd_register_value={};
	local running_speed_16 = string.format("%08x",running_speed);
	-- 拆解出高四位
	local high_running_speed_16 = string.sub(running_speed_16,1,4);
	-- 拆解出低四位
	local low_running_speed_16 = string.sub(running_speed_16,5,8);

	running_speed_cmd_register_value[0]=tonumber(high_running_speed_16,16);
	running_speed_cmd_register_value[1]=tonumber(low_running_speed_16,16);
	-- 写入多个寄存器
	mb_write_reg_16(64,12380,running_speed_cmd_register_value);
end
function ch3_absorb_liquid_running_speed(running_speed)
	local running_speed_cmd_register_value={};
	local running_speed_16 = string.format("%08x",running_speed);
	-- 拆解出高四位
	local high_running_speed_16 = string.sub(running_speed_16,1,4);
	-- 拆解出低四位
	local low_running_speed_16 = string.sub(running_speed_16,5,8);

	running_speed_cmd_register_value[0]=tonumber(high_running_speed_16,16);
	running_speed_cmd_register_value[1]=tonumber(low_running_speed_16,16);
	-- 写入多个寄存器
	mb_write_reg_16(64,12390,running_speed_cmd_register_value);
end



-- 设置夹爪运行速度
function set_clamp_jaw_running_speed(slave,addr,running_speed)
	-- local running_speed_int = tonumber(running_speed);
	local running_speed_cmd_register_value={};
	local running_speed_16 = string.format("%08x",running_speed);
	-- 拆解出高四位
	local high_running_speed_16 = string.sub(running_speed_16,1,4);
	-- 拆解出低四位
	local low_running_speed_16 = string.sub(running_speed_16,5,8);

	running_speed_cmd_register_value[0]=tonumber(high_running_speed_16,16);
	running_speed_cmd_register_value[1]=tonumber(low_running_speed_16,16);
	-- 写入多个寄存器
	mb_write_reg_16(slave,addr,running_speed_cmd_register_value);

end

function ch3_set_speed()
	-- ch3 设置运行速度
	local running_speed_cmd_register_value={}
	running_speed_cmd_register_value[0]=0x0000;
	running_speed_cmd_register_value[1]=0x7d00;
	-- 写入多个寄存器
	mb_write_reg_16(64,12390,running_speed_cmd_register_value);
	-- 起始速度
	local start_speed_cmd_register_value={}
	start_speed_cmd_register_value[0]=0x0000;
	start_speed_cmd_register_value[1]=0x0C80;
	-- 写入多个寄存器
	mb_write_reg_16(64,12392,start_speed_cmd_register_value);

	-- 加速时间
	local accumulate_time_cmd_register_value={}
	accumulate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12394,accumulate_time_cmd_register_value);

	-- 减速时间
	local decelerate_time_cmd_register_value={}
	decelerate_time_cmd_register_value[0]=0x00C8;
	-- 写入多个寄存器
	mb_write_reg_16(64,12395,decelerate_time_cmd_register_value);

	-- 停止速度
	local stop_speed_cmd_register_value={}
	stop_speed_cmd_register_value[0]=0x0000;
	stop_speed_cmd_register_value[1]=0x0640;
	-- 写入多个寄存器
	mb_write_reg_16(64,12396,stop_speed_cmd_register_value);

end

function ch2_goto_zero()
	count_i = 0;
	-- ch2上夹爪发送回原点操作
	local cmd_register_value = {};
	cmd_register_value[0]=0x0000;
	cmd_register_value[1]=0x0000;

	-- 写入多个寄存器
	mb_write_reg_16(64,10310,cmd_register_value);

	-- 开启定时器间隔一定时间读取设备状态
	start_timer(9,500,0,0);
end

function ch3_goto_zero()
	-- ch3下夹爪发送回原点操作
	local cmd_register_value = {};
	cmd_register_value[0]=0x0000;
	cmd_register_value[1]=0x0000;

	-- 写入多个寄存器
	mb_write_reg_16(64,10410,cmd_register_value);

	-- 开启定时器间隔一定时间读取设备状态
	start_timer(10,500,0,0);
end
function ch1_goto_zero()
	-- ch1上夹爪发送回原点操作
	local cmd_register_value = {};
	cmd_register_value[0]=0x0000;
	cmd_register_value[1]=0x0000;

	-- 写入多个寄存器
	mb_write_reg_16(64,10210,cmd_register_value);

	-- 开启定时器间隔一定时间读取设备状态
	start_timer(11,500,0,0);
end

function ch0_goto_zero()
	-- ch1上夹爪发送回原点操作
	local cmd_register_value = {};
	cmd_register_value[0]=0x0000;
	cmd_register_value[1]=0x0000;

	-- 写入多个寄存器
	mb_write_reg_16(64,10110,cmd_register_value);

	-- 开启定时器间隔一定时间读取设备状态
	start_timer(8,500,0,0);
end


-- 回原点操作
function goto_zero(slave,addr)
	-- count_i = 0;

	-- 发送回原点操作
	local cmd_register_value = {};
	cmd_register_value[0]=0x0000;
	cmd_register_value[1]=0x0000;

	-- 写入多个寄存器
	mb_write_reg_16(slave,addr,cmd_register_value);

	-- 开启定时器间隔一定时间读取设备状态
	start_timer(9,100,0,0);

end
-- 持续获取当前位置
-- function continous_get_current_position(slave,addr)
function continous_get_current_position()
	while true do

		local ch2_current_position = current_position(64,10310);
		local ch3_current_position = current_position(64,10410);
		local ch1_current_position = current_position(64,10210);

		-- set_text(4,11,ch1_current_position);
		-- set_text(4,12,ch2_current_position);
		-- set_text(4,13,ch3_current_position);

	end

end

-- 启动即检测吸液触发信号，间隔500ms
function enable_start_absorb_liquid_singnal(slave)
	-- 读取数字量信号
	-- 读取状态位
	local status = mb_read_reg_03(slave,11999,1);
	-- set_text(4,21,status[0]);
	local bit4_value_bin16_str = int_to_bin16_str(status[0]);
	local bit4_value_str = string.sub(bit4_value_bin16_str,12,12);
	-- set_text(4,16,bit4_value_str);
	return bit4_value_str
end
