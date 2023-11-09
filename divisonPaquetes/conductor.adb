with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;


package body conductor is
        function GetGiroVolante return Steering_Samples_Type is
        Current_GiroVolante : Steering_Samples_Type;
        begin
            Reading_Steering (Current_GiroVolante);
            return Current_GiroVolante;
        end GetGiroVolante;
        
        procedure PutGiroVolante(giro :  Steering_Samples_Type) is
        begin
            Current_GiroVolante := giro;
        end PutGiroVolante;
        
        function GetDistancia return Distance_Samples_Type is
        Current_Dist : Distance_Samples_Type;
        begin
         Reading_Distance(Current_Dist);
         return Current_Dist;
        end GetDistancia;
        
        procedure PutDistancia(dist : Distance_Samples_Type) is
        begin
            Current_Dist := dist;
        end PutDistancia;
        
        function GetVelocidad return Speed_Samples_Type is
        Current_vel : Speed_Samples_Type ;
        begin
         Reading_Speed(Current_Vel);
         return Current_Vel;
        end GetVelocidad;
        
        procedure PutVelocidad(vel : Speed_Samples_Type) is
        begin
            Current_Vel := vel;
        end PutVelocidad;
        
        function GetPosCabeza return HeadPosition_Samples_Type is
        Current_Cab : HeadPosition_Samples_Type;
        begin
         Reading_HeadPosition(Current_Cab);
         return Current_Cab;
        end GetPosCabeza;
        
        procedure PutPosCabeza(cab : HeadPosition_Samples_Type) is
        begin
            Current_Cab := cab;
        end PutPosCabeza;
end conductor;