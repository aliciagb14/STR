with Kernel.Serial_Output; use Kernel.Serial_Output;
with Ada.Real_Time; use Ada.Real_Time;
with System; use System;

with Tools; use Tools;
with Devices; use Devices;
package coche is
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
end coche;