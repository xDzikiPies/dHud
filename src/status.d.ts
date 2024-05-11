export interface userData {
    name: String,
    id: number,
    armor: number,
    health: number,
    energy: number,
    food: number,
    drink: number,
    job: String,
    rankLabel: String,
    talkingMode: number,
    underwaterTime: number,
    underwater: Boolean,
    isTalking: Boolean,
    streetName: String,
    direction: String,
}
export type StatusContextType = {
    userData: userData[];
    setUserData: (data: any) => void;
};