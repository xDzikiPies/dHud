import React, { createContext, useContext, useState, ReactNode } from "react";
import { useNuiEvent } from "fivem-nui-react-lib";

interface VehicleData {
    speed: number;
    fuel: number;
    rpm: number;
    gear: number;
    engineHealth: number;
    carLights: number;
    inCar: boolean;
    engineOn: boolean;
    seatbelt: boolean;
}

interface VehicleContextType {
    vehData: VehicleData;
    setVehData: React.Dispatch<React.SetStateAction<VehicleData>>;
}

const VehicleContext = createContext<VehicleContextType | undefined>(undefined);

export const VehicleProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
    const [vehData, setVehData] = useState<VehicleData>({
        speed: 0,
        fuel: 65,
        rpm: 0.2,
        gear: 1,
        engineHealth: 60.0,
        carLights: 0,
        inCar: false,
        engineOn: false,
        seatbelt: false
    });

    useNuiEvent('dHud', 'update-veh-data', (data: VehicleData) => {
        setVehData(data)
    })

    return (
        <VehicleContext.Provider value={{ vehData, setVehData }}>
            {children}
        </VehicleContext.Provider>
    );
};

export const useVehicle = (): VehicleContextType => {
    const context = useContext(VehicleContext);
    if (context === undefined) {
        throw new Error("useVehicle must be used within a VehicleProvider");
    }
    return context;
};
