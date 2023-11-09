with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;
with conductor; use conductor;


package body coche is
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


      
      task DistanciaSeguridad is
      pragma priority(4);
      end DistanciaSeguridad;

      task Cabeza is
      pragma priority(2);
      end Cabeza;

      task GiroVolante is
      pragma priority(3);
      end GiroVolante;

      task Riesgos is 
      pragma priority(5);
      end Riesgos;

      task Display is
       pragma priority(1);
      end Display;

      task body Riesgos is
      Sig_Instante : Time;
      Intervalo: Time_Span := Milliseconds(150);
      begin
      loop
         Starting_Notice("Inicio Riesgos");
         if (GetAvisoDistancia = 2) then
            Light(On);
            Beep(4);
         elsif (GetAvisoDistancia = 1) then
            Light(On);
         end if;
         if (GetAvisoVolante) then
            Beep(1);
         end if;

         if (GetAvisoCabeza and GetAvisoDistancia = 3) then
            Beep(5);
            Activate_Brake;
         elsif (GetAvisoCabeza and conductor.GetVelocidad > 70) then
            Beep(3);
         elsif (GetAvisoCabeza) then
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
            Current_Vel := conductor.GetVelocidad;
            Current_Dist := conductor.GetDistancia;

            distSeg:= (Distance_Samples_Type(Current_Vel) / 10) * (Distance_Samples_Type(Current_Vel) / 10);
            if (Current_Dist < (distSeg / 3)) then
                PutAvisoDistancia(3);
            elsif (Current_Dist < (distSeg / 2)) then
                  PutAvisoDistancia(2);
            elsif (Current_Dist < distSeg) then
                PutAvisoDistancia(1);
            else PutAvisoDistancia(0);
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
         Current_Cab := conductor.GetPosCabeza;
         conductor.PutPosCabeza(Current_Cab);
         Current_GiroVolante := conductor.GetGiroVolante;
         conductor.PutGiroVolante(Current_GiroVolante);

         if (((Steering_Samples_Type(Current_Cab(y)) /= Current_GiroVolante) and abs(Current_Cab(y)) > 30 and abs(lecturaAnteriorCabeza(y)) > 30) or 
            (abs(Current_Cab(x)) > 30 and abs(lecturaAnteriorCabeza(x)) > 30)) then
            PutAvisoCabeza(true);
         else PutAvisoCabeza(false);
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
         Current_GiroVolante := conductor.GetGiroVolante;
         VelocidadActual := conductor.GetVelocidad;

         if (abs(Current_GiroVolante - lecturaAnterior) > Umbral_Volantazo and (VelocidadActual > 40)) then
            PutAvisoVolante(true);
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
        Display_Distance(conductor.GetDistancia);
        Display_Speed(conductor.GetVelocidad);
      if (GetAvisoDistancia = 3) then
            Put_line("(*)PELIGRO COLISION");
            New_line;
         elsif (GetAvisoDistancia = 2) then
            Put_line("(*)DISTANCIA IMPRUDENTE");
            New_line;
         elsif (GetAvisoDistancia = 1) then
            Put_line("(*)DISTANCIA INSEGURA");
            New_line;
         end if;
         if (GetAvisoVolante) then
            Put_line("(*)VOLANTAZO");
            New_line;
         end if;
         New_line;
         if (GetAvisoCabeza) then
            Put_line("(*)DISTRACCION O SOMNOLENCIA");
            New_line;
         end if;
       Finishing_Notice("Fin display");
      delay until Sig_Instante;
        Sig_Instante := Sig_Instante + Intervalo;
      end loop;
      end Display;
end coche;