with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;

-- Packages needed to generate pulse interrupts UTILIZAMOS LA ESTATICA      
with Ada.Interrupts.Names;
with Pulse_Interrupt; use Pulse_Interrupt;

with conductor; use conductor;
with vehiculo; use vehiculo;
package body add is

    ----------------------------------------------------------------------
    ------------- procedure exported 
    ----------------------------------------------------------------------
    
    protected Controlador_Eventos is
    	pragma Priority(16);
    	procedure Interrupcion;
    	pragma Attach_Handler(Interrupcion, 16);
    	
    	entry Esperar_Evento;
    	private
    	    Llamada_Pendiente : Boolean := False;
    end Controlador_Eventos;
    
    ----------------------------------------------------------------------

    -----------------------------------------------------------------------
    ------------- declaration of tasks 
    -----------------------------------------------------------------------

    task Modo is 
    	pragma priority(6);
    end Modo;
   

    -----------------------------------------------------------------------
    ------------- body of tasks 
    -----------------------------------------------------------------------
   
    -- tarea esporadica
    Task body Modo is
    	type ModoFuncionamiento is (M1, M2, M3);
    	modo : ModoFuncionamiento := M1;
    	
        begin
        loop
          Controlador_Eventos.Esperar_Evento;
	    case modo is
	        when M1 => 
	            if (Sintomas.GetAvisoDistancia /= 3) then
	            	modo := M2;
	            end if;
	       when M2 => 
	            if (Sintomas.GetAvisoCabeza = false or Sintomas.GetAvisoDistancia /= 3) then
	            	modo := M3;
	            end if;
	      when M3 =>
	            	modo := M1;
	     end case;
	
	end loop;
    end Modo;
    
    ----------------------------------------------------------------------
    ------------- protected body
    ----------------------------------------------------------------------
    protected body Controlador_Eventos is
       procedure Interrupcion is
          begin
    	    Llamada_Pendiente := true;
          end Interrupcion;
       entry Esperar_Evento when Llamada_Pendiente is
           begin
              Llamada_Pendiente := false;
       end Esperar_Evento;
    end Controlador_Eventos;
   
  
    
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
   Prueba_Dispositivos;
   Finishing_Notice ("Programa Principal");
end add;
