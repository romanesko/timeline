import {writable} from 'svelte/store';

// export const types = writable([])
// export const main = writable({});
// export const selectedKeys = writable({});
// export const selectedType = writable(undefined);


export const currentUser = writable(undefined);
export const selected = writable({});
export const slotsInfo = writable({});
export const hasChanges = writable(false);
export const zones = writable([]);

let storedSettings = {
  daysCount: 35,
  slotSizeX: 20,
  slotSizeY: 20,
}

try {
  if (localStorage.getItem('settings')) {
    let set = JSON.parse(localStorage.getItem('settings'))
    if (set && typeof set === 'object') {
      storedSettings = set
    }
  }
} catch (e) {
  console.log(e)
}

export const settings = writable(storedSettings);

settings.subscribe(a => {
  localStorage.setItem('settings', JSON.stringify(a))
})