--Adrian Tello Jimenez y Alicia Gonzalez Berrocal
--add con medidas, sintomas, riesgos, Distancia de seguridad, cabeza, giro volante y todos sus avisos correspondientes. ademas de objetos protegidos para cada uno de los tipos.

with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;


package body add is

    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    procedure Background is
    begin
      loop
        null;
      end loop;
    end Background;
    
    protected Medidas is
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
    end Medidas;

    protected Sintomas is 
      procedure PutAvisoCabeza(avisoCabeza:boolean);
      procedure PutAvisoDistancia(avisoDistancia:integer);
      procedure PutAvisoVolante(avisoVolante:boolean);
         function GetAvisoCabeza return boolean;
         function GetAvisoDistancia return integer;
         function GetAvisoVolante return boolean;
    private
      Current_AvisoCabeza: boolean;
      Current_AvisoDistancia: integer;
      Current_AvisoVolante: boolean;
    end Sintomas;
    
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

   task Display is
       pragma priority(1);
    end Display;

   task Cabeza is
      pragma priority(2);
   end Cabeza;
    
   task GiroVolante is
      pragma priority(3);
   end GiroVolante;


   task DistanciaSeguridad is
        pragma priority(4);
   end DistanciaSeguridad;
    
   task Riesgos is 
      pragma priority(5);
   end Riesgos;
    

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
    task body Riesgos is
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(150);
    begin
      loop
         Starting_Notice("Inicio Riesgos");
         if (Sintomas.GetAvisoDistancia = 2) then
            Light(On);
            Beep(4);
         elsif (Sintomas.GetAvisoDistancia = 1) then
            Light(On);
         end if;
         if (Sintomas.GetAvisoVolante) then
            Beep(1);
         end if;
     
         if (Sintomas.GetAvisoCabeza and Sintomas.GetAvisoDistancia = 3) then
            Beep(5);
            Activate_Brake;
         elsif (Sintomas.GetAvisoCabeza and Medidas.GetVelocidad > 70) then
            Beep(3);
         elsif (Sintomas.GetAvisoCabeza) then
            Beep(2);
         end if;
         Finishing_Notice("Fin Riesgos");
         delay until Sig_Instante;
         Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end Riesgos;
    
    task body DistanciaSeguridad is
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(300);
    Current_Vel: Speed_Samples_Type;
    Current_Dist: Distance_Samples_Type;
    distSeg : Distance_Samples_Type := 0;
    begin
      Sig_Instante := Clock + Intervalo;
         loop 
            Starting_Notice("Inicio distancia seguridad");
            Current_Vel := Medidas.GetVelocidad;
            Current_Dist := Medidas.GetDistancia;

            distSeg:= (Distance_Samples_Type(Current_Vel) / 10) * (Distance_Samples_Type(Current_Vel) / 10);
            if (Current_Dist < (distSeg / 3)) then
                Sintomas.PutAvisoDistancia(3);
            elsif (Current_Dist < (distSeg / 2)) then
                  Sintomas.PutAvisoDistancia(2);
            elsif (Current_Dist < distSeg) then
                Sintomas.PutAvisoDistancia(1);
            else Sintomas.PutAvisoDistancia(0);
            end if; 
            Finishing_Notice("Fin distancia seguridad");
            delay until Sig_Instante;
            Sig_Instante := Sig_Instante + Intervalo;
         end loop;
    end DistanciaSeguridad;
    
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
         Finishing_Notice("Fin cabeza");
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
         Finishing_Notice("Fin giro volante");
         delay until Sig_Instante;
         Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end GiroVolante;
     
    task body Display is
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(1000);
    Current_Distancia : Distance_Samples_Type;
    Current_Vel : Speed_Samples_Type;
    begin
    loop
        Starting_Notice("Inicio display");
        Display_Distance(Medidas.GetDistancia);
        Display_Speed(Medidas.GetVelocidad);
    	if (Sintomas.GetAvisoDistancia = 3) then
            Put_line("(*)PELIGRO COLISION");
            New_line;
         elsif (Sintomas.GetAvisoDistancia = 2) then
            Put_line("(*)DISTANCIA IMPRUDENTE");
            New_line;
         elsif (Sintomas.GetAvisoDistancia = 1) then
            Put_line("(*)DISTANCIA INSEGURA");
            New_line;
         end if;
         if (Sintomas.GetAvisoVolante) then
            Put_line("(*)VOLANTAZO");
            New_line;
         end if;
         New_line;
         if (Sintomas.GetAvisoCabeza) then
            Put_line("(*)DISTRACCION O SOMNOLENCIA");
            New_line;
         end if;
    	 Finishing_Notice("Fin display");
    	delay until Sig_Instante;
        Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end Display;
    
    
    ----------------------------------------------------------------------
    ------------- protected body
    ----------------------------------------------------------------------
    
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
    

    
    ----------------------------------------------------------------------
    ------------- procedure para probar los dispositivos 
    ----------------------------------------------------------------------
    procedure Prueba_Dispositivos; 

    Procedure Prueba_Dispositivos is
        --Current_V: Speed_Samples_Type := 0;
        --Current_H: HeadPosition_Samples_Type := (+2,-2);
        --Current_D: Distance_Samples_Type := 0;
       -- Current_O: Eyes_Samples_Type := (70,70);
       -- Current_E: EEG_Samples_Type := (1,1,1,1,1,1,1,1,1,1);
       -- Current_S: Steering_Samples_Type := 0;
    begin
         Starting_Notice ("Prueba_Dispositivo");

         for I in 1..120 loop
         -- Prueba distancia
          --  Reading_Distance (Current_D);
         --   Display_Distance (Current_D);
             -- if (Current_D < 40) then Light (On); 
             --              else Light (Off); end if;

         -- Prueba velocidad
           -- Reading_Speed (Current_V);
         --   Display_Speed (Current_V);
          --  if (Current_V > 110) then Beep (2); end if;

         -- Prueba volante
          --  Reading_Steering (Current_S);
         --   Display_Steering (Current_S);
         --   if (Current_S > 30) OR (Current_S < -30) then Light (On);
          --                                           else Light (Off); end if;

         -- Prueba Posicion de la cabeza
        --    Reading_HeadPosition (Current_H);
        --    Display_HeadPosition_Sample (Current_H);
         --   if (Current_H(x) > 30) then Beep (4); end if;

         -- Prueba ojos
        --    Reading_EyesImage (Current_O);
        --    Display_Eyes_Sample (Current_O);

         -- Prueba electroencefalograma
         --   Reading_Sensors (Current_E);
         --   Display_Electrodes_Sample (Current_E);
            
   
         delay until (Clock + To_time_Span(0.1));
         end loop;

         Finishing_Notice ("Prueba_Dispositivo");
    end Prueba_Dispositivos;


begin
   Starting_Notice ("Programa Principal");
   --Prueba_Dispositivos;
   Finishing_Notice ("Programa Principal");
end add;
