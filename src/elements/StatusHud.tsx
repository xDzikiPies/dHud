import { useState, useEffect} from "react";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faHeart } from "@fortawesome/free-regular-svg-icons";
import { faBolt, faDroplet, faBurger, faMicrophone } from "@fortawesome/free-solid-svg-icons";
import { useStatus } from "../contexts/StatusContext";
import { motion } from "framer-motion";
import { useVehicle } from "../contexts/VehicleContext";
import { useNuiEvent } from "fivem-nui-react-lib";

interface HudData {
    icon: any; 
    value: number | string;
    specialCss?: boolean;
}

const StatusHud = () => {
    const { userData } = useStatus()
    const { vehData } = useVehicle()
    const [isTalking, setIsTalking] = useState(false);
    const [hudStyles] = useState({
        health: {
            bgcolor: '#352F44',
            stroke: '#5C5470',
            color: '#DBD8E3'
        }
    })

    useNuiEvent('dHud', 'toggle-voice', (data: boolean) => {
        setIsTalking(data);
    });

    const getTalkingCss = () => {
        return isTalking ? '#9d84e0' : '#DBD8E3'
    }


    useEffect(() => {
        const getTalkingValue = () => {
            let value;
            if (userData.talkingMode === 1) {
                value = 33;
            } else if (userData.talkingMode === 2) {
                value = 66;
            } else if (userData.talkingMode === 3) {
                value = 100;
            }
            return String(value);
        };

        const newHudData = [
            {
                icon: faHeart,
                value: userData.health
            },
            {
                icon: faBurger,
                value: userData.food
            },
            {
                icon: faDroplet,
                value: userData.drink
            },
            {
                icon: faBolt,
                value: userData.energy
            },
            {
                icon: faMicrophone,
                value: getTalkingValue(),
                specialCss: true
            }
        ];

        setHudData(newHudData);
    }, [userData]);

    const [hudData, setHudData] = useState<HudData[]>([]);

    return (
        <>
            <div className={`statuswrapper${vehData.inCar ? '-car' : ''}`}>
                {hudData.map((icon, id) => (
                    <motion.div className="huditemwrapper"
                        key={id}
                        initial={{ y: '100%', opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        exit={{ y: '100%', opacity: 0 }}
                        transition={{ delay: 0.5 }}
                    >
                        <svg height="100" width="100" className='huditem' >
                            <circle cx="50%" cy="50%" r={23} stroke={hudStyles['health'].bgcolor}
                                strokeWidth="3" fill={hudStyles['health'].bgcolor} className='outercircle' />

                            <circle className='progress' cx="50%" cy="50%" r={23}
                                stroke={hudStyles['health'].color} strokeWidth="3.2" fill="transparent"
                                pathLength={100} strokeDasharray={`${icon.value} 100`} strokeLinecap='round' />
                        </svg>
                        <FontAwesomeIcon className="statusicon" key={id} icon={icon.icon} fontSize={23} color={icon.specialCss ? getTalkingCss() : hudStyles['health'].color} />
                    </motion.div>
                ))}
            </div>
        </>
    );
}

export default StatusHud;

