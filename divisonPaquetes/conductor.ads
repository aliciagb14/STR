with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;
package conductor is
      procedure PutGiroVolante(giro : Steering_Samples_Type);
      procedure PutDistancia(dist : Distance_Samples_Type);
      procedure PutVelocidad(vel : Speed_Samples_Type);
      procedure PutPosCabeza(cab : HeadPosition_Samples_Type);
      
         function GetGiroVolante return Steering_Samples_Type;
         function GetDistancia return Distance_Samples_Type;
         function GetVelocidad return Speed_Samples_Type;
         function GetPosCabeza return HeadPosition_Samples_Type;
private
      Current_GiroVolante: Steering_Samples_Type;
      Current_Vel: Speed_Samples_Type;
      Current_Dist: Distance_Samples_Type;
      Current_Cab: HeadPosition_Samples_Type;
end conductor;