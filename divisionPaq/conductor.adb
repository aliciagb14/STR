with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Tools; use Tools;
with Devices; use Devices;


package body Conductor is

protected body Medidas is
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
      
        
    end Medidas;

 protected body Sintomas is 

        function GetAvisoCabeza return boolean is
        begin
            return Current_AvisoCabeza;
        end GetAvisoCabeza;
        
        procedure PutAvisoCabeza(avisoCabeza :  boolean) is
        begin
            Current_AvisoCabeza := avisoCabeza;
        end PutAvisoCabeza;
        
        function GetAvisoVolante return boolean is
        begin
         return Current_AvisoVolante;
        end GetAvisoVolante;
        
        procedure PutAvisoVolante(avisoVolante : boolean) is
        begin
            Current_AvisoVolante := avisoVolante;
        end PutAvisoVolante;
        
        function GetAvisoDistancia return integer is
        begin
         return Current_AvisoDistancia;
        end GetAvisoDistancia;

        procedure PutAvisoDistancia(avisoDistancia : integer) is
        begin
            Current_AvisoDistancia := avisoDistancia;
        end PutAvisoDistancia;

    end Sintomas;

  task body Cabeza is
    Current_Cab: HeadPosition_Samples_Type := (0,0);
    Current_GiroVolante: Steering_Samples_Type := 0;
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(400);
    lecturaAnteriorCabeza : HeadPosition_Samples_Type:= (0,0);
    begin
      Sig_Instante := Clock + Intervalo;
      loop
      	 Starting_Notice("Inicio cabeza");
         Current_Cab := Medidas.GetPosCabeza;
         Medidas.PutPosCabeza(Current_Cab);
         Current_GiroVolante := Medidas.GetGiroVolante;
         Medidas.PutGiroVolante(Current_GiroVolante);

         if (((Steering_Samples_Type(Current_Cab(y)) /= Current_GiroVolante) and abs(Current_Cab(y)) > 30 and abs(lecturaAnteriorCabeza(y)) > 30) or 
            (abs(Current_Cab(x)) > 30 and abs(lecturaAnteriorCabeza(x)) > 30)) then
            Sintomas.PutAvisoCabeza(true);
         else Sintomas.PutAvisoCabeza(false);
         end if;
         Finishing_Notice("Fin cabeza"); New_line;
         lecturaAnteriorCabeza:=Current_Cab;

         delay until Sig_Instante;
         Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end Cabeza;
    
    task body GiroVolante is
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(350);
    Current_GiroVolante : Steering_Samples_Type := 0;
    lecturaAnterior : Steering_Samples_Type := 0;
    
    Umbral_Volantazo : constant Steering_Samples_Type := 20;
    VelocidadActual: Speed_Samples_Type;
    begin
      loop
         Starting_Notice("Inicio giro volante");
         lecturaAnterior := Current_GiroVolante;
         Current_GiroVolante := Medidas.GetGiroVolante;
         VelocidadActual := Medidas.GetVelocidad;

         if (abs(Current_GiroVolante - lecturaAnterior) > Umbral_Volantazo and (VelocidadActual > 40)) then
            Sintomas.PutAvisoVolante(true);
         end if;
         Finishing_Notice("Fin giro volante"); New_line;
         delay until Sig_Instante;
         Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end GiroVolante;

end Conductor;
