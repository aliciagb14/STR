with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;
with Tools; use Tools;
with Devices; use Devices;
with conductor; use conductor;

package body Vehiculo is
  
 task body Riesgos is
    Sig_Instante : Time;
    Intervalo: Time_Span := Milliseconds(150);
    begin
      loop
         if (Sintomas.GetAvisoDistancia = 2) then
            Light(On);
            Beep(4);
         elsif (Sintomas.GetAvisoDistancia = 1) then
            Light(On);
         end if;
         
         if (Sintomas.GetAvisoVolante) then
            Beep(1);
            New_line;
         end if;
     
         if (Sintomas.GetAvisoCabeza and Sintomas.GetAvisoDistancia = 3) then
            Beep(5);
            Activate_Brake;
         elsif (Sintomas.GetAvisoCabeza and Medidas.GetVelocidad > 70) then
            Beep(3);
         elsif (Sintomas.GetAvisoCabeza) then
            Beep(2);
         end if;
         New_line;
         Put_line("---------------------------------------------------------------------");
    
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
            Finishing_Notice("Fin distancia seguridad"); New_line;
            delay until Sig_Instante;
            Sig_Instante := Sig_Instante + Intervalo;
         end loop;
    end DistanciaSeguridad;
    
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
            Put ("............# ");
            Put_line("(*)PELIGRO COLISION");
            New_line;
         elsif (Sintomas.GetAvisoDistancia = 2) then
            Put ("............# ");
            Put_line("(*)DISTANCIA IMPRUDENTE");
            New_line;
         elsif (Sintomas.GetAvisoDistancia = 1) then
            Put ("............# ");
            Put_line("(*)DISTANCIA INSEGURA");
            New_line;
         end if;
         if (Sintomas.GetAvisoVolante) then
            Put ("............# ");
            Put_line("(*)VOLANTAZO");
            New_line;
         end if;
         New_line;
         if (Sintomas.GetAvisoCabeza) then
            Put ("............# ");
            Put_line("(*)DISTRACCION O SOMNOLENCIA");
            New_line;
         end if;
         New_line;
         Put_line("---------------------------------------------------------------------");
    	 Finishing_Notice("Fin display");
    	delay until Sig_Instante;
        Sig_Instante := Sig_Instante + Intervalo;
      end loop;
    end Display;

end Vehiculo;
