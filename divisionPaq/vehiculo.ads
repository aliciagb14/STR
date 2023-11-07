with Tools; use Tools;
with Devices; use Devices;

package Vehiculo is
    
   task Display is
       pragma priority(1);
    end Display;
    
    task DistanciaSeguridad is
        pragma priority(4);
    end DistanciaSeguridad;
    
    task Riesgos is 
      pragma priority(5);
    end Riesgos;
    
    
end Vehiculo;
