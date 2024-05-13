import {writable} from 'svelte/store';

export const types = writable([])
export const main = writable({});
export const selectedKeys = writable({});
export const selectedType = writable(undefined);
export const currentUser = writable(undefined);


export const selected = writable({});
export const slotsInfo = writable({});

