import { useState } from 'react'
import { motion } from "framer-motion"
import StatusHud from './elements/StatusHud';
import CarHud from './elements/CarHud';
import './App.scss'
import { useNuiEvent } from "fivem-nui-react-lib";
import { useVehicle } from './contexts/VehicleContext';

function App() {
  const [ui, setUi] = useState(true); // Hud włączony lub wyłączony
  const { vehData } = useVehicle()
  const [phoneUp, setPhoneUp] = useState(false);

  
  useNuiEvent('dHud', 'update-phone-up', (data: boolean) => {
    setPhoneUp(data);
});

  useNuiEvent('dHud', 'state', (enabled: boolean) => {
    setUi(enabled)
  })

  return (
    <>
      {
        ui ?
          <motion.div
            className='container'
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <div className={`statushudcont`}>
              <StatusHud />
            </div>

            {
              vehData.inCar ? <div className={`carhudcont${phoneUp ? '-phone' : ''}`}>
                <CarHud />
              </div> : null
            }


          </motion.div>
          : null
      }

    </>
  )
}

export default App
