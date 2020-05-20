/*
 * This is a logi.CAD 3 program template
 */
PROGRAM RevolutionPiProgram
	
	VAR 
		a : STRING[2];
		trigger : BOOL := TRUE;
		rcvPayload : STRING[5] :='' ;
		ch : DINT := -1 ;
		rc : DINT := -1 ;
		state : SINT := -1 ;
		subscribed : BOOL := FALSE ;
		message_recieved : BOOL := FALSE ;
		sendData : BOOL;
		RTSS_MQTT_OK : DINT :=0;
	END_VAR
	
	VAR_EXTERNAL
		O_1 : BOOL;
		O_3 : BOOL;
		I_1 : BOOL;
		Fan : INT;
	END_VAR
	trigger := TRUE  ;
	ENO := TRUE ;
	state := MQTT_GetState(ch:= ch, rc => rc, ENO => ENO);
	
	IF state <> 5 AND state <> 6 THEN
	 ch := MQTT_Connect(address:='192.168.0.10', clientId:='RevPi', rc => rc, ENO => ENO);
	END_IF ;
	
	IF state = 6 THEN

		IF I_1 <> TRIGGER THEN 
			IF I_1 THEN
				a:='OF';
			ELSE 
				a:='ON' ;
			END_IF ;
			MQTT_Publish(ch:=ch,topic:='RevPiObox',rc => rc,payload := GET_BYTE_REF(IN := a),len:=2);
			TRIGGER := I_1 ;
		END_IF ;
		
		
		IF NOT(subscribed) THEN
			MQTT_Subscribe(ch:=ch, topic:='RevPiInbox',rc => rc) ;
			subscribed := rc = RTSS_MQTT_OK ;
			
		END_IF ;
		
		IF subscribed THEN
			message_recieved := FALSE ;
			REPEAT
				MQTT_Receive(ch := ch, payload := GET_BYTE_REF(IN := rcvPayload),payload_len:= 5,rc => rc);
				IF rc <> RTSS_MQTT_OK THEN
					Fan := TO_INT((rcvPayload[1])) * 1000;
					O_3 := TO_BOOL(TO_WORD(rcvPayload[2]));
					EXIT;
				END_IF ;
				message_recieved := TRUE ; 
			UNTIL TRUE
			END_REPEAT ;
		END_IF ;
	END_IF;
END_PROGRAM
