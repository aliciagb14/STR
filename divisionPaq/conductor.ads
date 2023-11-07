with Tools; use Tools;
with Devices; use Devices;

package Conductor is
    task Cabeza is
      pragma priority(2);
    end Cabeza;
    
    task GiroVolante is
      pragma priority(3);
    end GiroVolante;
    
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
end Conductor;

