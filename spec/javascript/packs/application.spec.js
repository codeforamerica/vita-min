import {double} from "packs/application";
import {describe} from "@jest/globals";

describe("Application", () => {
    test("can double an integer", () => {
        expect(double(2)).toEqual(4);
    });
});
