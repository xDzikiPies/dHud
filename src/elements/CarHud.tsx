import { useVehicle } from "../contexts/VehicleContext";
import { PiSeatbelt, PiEngine, PiHeadlights } from "react-icons/pi";
import { LuFuel } from "react-icons/lu";
import { motion } from "framer-motion";
// @ts-ignore
import NumberEasing from 'react-number-easing';
import { useNuiEvent } from "fivem-nui-react-lib";
import { useState } from "react";

const CarHud = () => {
    const { vehData } = useVehicle()
    const [seatbelt, setSeatbelt] = useState(false);
    useNuiEvent('dHud', 'update-seatbelt', (data: boolean) => {
        setSeatbelt(data);
    })
    const calculateSpeed = () => {
        let string = '';

        if (vehData.speed < 10) {
            string = '00' + String(vehData.speed)
        } else if (vehData.speed < 100 && vehData.speed >= 10) {
            string = '0' + String(vehData.speed)
        } else if (vehData.speed >= 100) {
            string = String(vehData.speed)
        }


        return <NumberEasing value={Number(string)} speed={500} ease='quintInOut'/>
    }

    const getHeadlightsColor = () => {
        let hex = '';

        if (vehData.carLights === 0) {
            hex = '#DBD8E3';
        } else if (vehData.carLights === 1) {
            hex = '#0441db';
        } else if (vehData.carLights === 2) {
            hex = '#edb90c';
        } else {
            hex = '#DBD8E3'
        }

        return hex
    }

    const getEngineColor = () => {
        let hex = '';

        if (vehData.engineHealth >= 65) {
            hex = '#DBD8E3'
        } else if (vehData.engineHealth >= 30 && vehData.engineHealth < 65) {
            hex = '#edb90c'
        } else {
            hex = '#ed373d'
        }

        return hex
    }

    const getFuelColor = () => {
        let hex = '';

        if (vehData.fuel >= 50) {
            hex = '#DBD8E3';
        } else if (vehData.fuel <= 50 && vehData.fuel >= 15) {
            hex = '#edb90c'
        } else {
            hex = '#ed373d'
        }

        return hex
    }

    return (
        <motion.div
            className={`carhudwrapper`}
            initial={{ y: '100%', opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: '100%', opacity: 0 }}
            transition={{delay: 0.8}}>
            <div className="speedocont">
                <div className="speed">
                    {calculateSpeed()}
                </div>
                <div className="enginespeedcont">
                    <div className="outer">
                        <div className="inner" style={{width: `${vehData.rpm * 100}%`}}></div>
                    </div>
                </div>
            </div>
            <div className="iconscont">
                <div className="mph">
                    <p>MPH</p>
                </div>
                <div className="iconswrapper">
                    <div className="belt">
                        <PiSeatbelt fontSize={30} className='seatbelt' color={`${seatbelt ? '#DBD8E3' : '#ed373d'}`} />
                    </div>
                    <div className="enginehealth">
                        <PiEngine color={getEngineColor()} fontSize={30} />
                    </div>
                    <div className="lights">
                        <PiHeadlights color={getHeadlightsColor()} fontSize={30} />
                    </div>
                    <div className="fuel">
                        <div className="icon">
                            <LuFuel color={getFuelColor()} fontSize={30} />
                        </div>
                        <div className="fuelouter">
                            <div className="fuelinner" style={{height: `${vehData.fuel}%`, backgroundColor: getFuelColor()}}></div>
                        </div>
                    </div>
                </div>
            </div>
        </motion.div>
    );
}

export default CarHud;