import {describe, expect, test} from '@jest/globals';

describe('True test', () => {
    test('Just passes the test :)', () => {
        expect(true)
            .toBe(true);
    });
});