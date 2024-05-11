import React, { createContext, useContext, useState, ReactNode } from "react";
import { useNuiEvent } from "fivem-nui-react-lib";

interface UserData {
    name: string;
    id: number;
    armor: number;
    health: number;
    energy: number;
    food: number;
    drink: number;
    job: string;
    rankLabel: string;
    talkingMode: number;
    underwaterTime: number;
    underwater: boolean;
    isTalking: boolean;
    streetName: string;
    direction: string;
}

interface StatusContextType {
    userData: UserData;
    setUserData: React.Dispatch<React.SetStateAction<UserData>>;
}

const StatusContext = createContext<StatusContextType | undefined>(undefined);

export const StatusProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
    const [userData, setUserData] = useState<UserData>({
        name: 'John Kondon',
        id: 5,
        armor: 20,
        health: 60,
        energy: 50,
        food: 90,
        drink: 10,
        job: 'Brak',
        rankLabel: 'brak',
        talkingMode: 1,
        underwaterTime: 10.0,
        underwater: false,
        isTalking: false,
        streetName: 'Rockford Hills',
        direction: 'N',
    });

    useNuiEvent('dHud', 'voice-range', (mode: number) => {
        setUserData(prevData => ({
            ...prevData,
            talkingMode: mode,
        }));
    });

    useNuiEvent('dHud', 'update-user-data', (data: any) => {
        setUserData(data)
    })

    return (
        <StatusContext.Provider value={{ userData, setUserData }}>
            {children}
        </StatusContext.Provider>
    );
};

export const useStatus = (): StatusContextType => {
    const context = useContext(StatusContext);
    if (context === undefined) {
        throw new Error("useStatus must be used within a StatusProvider");
    }
    return context;
};
