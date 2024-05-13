<main bind:this={main} style="min-height: 100lvh; padding:10px">



    <div class="flex mb-2 gap-2 items-center">
        <div class="w-max-20"><Input size="sm" id="minDate" on:change={handleDateChange} bind:value={minDate} name="minDate" required type="date" /></div>
        <div class="w-max-20"><Button size="xs" outline >Сохранить</Button></div>
        <div class="ml-4 text-xs text-gray-500">
            hint: для выбора нескольких слотов — выделите область удерживайте кнопку мыши
        </div>
    </div>

    <div class="flex mb-2 gap-2">
        {#each types as type}
            <Badge color="dark" border style="background-color: {type.color}; color: #fff">{type.label}</Badge>
        {/each}
    </div>


    <canvas bind:this={canvas} height="740" id="canvas" width={canvasWidth}></canvas>

    <div bind:this={menuEl} role="tooltip" tabindex="-1" style="position:absolute; left:{menuPosition.x}px; top:{menuPosition.y}px; " class="bg-white dark:bg-gray-800 text-gray-500 dark:text-gray-400 rounded-lg border border-gray-200 dark:border-gray-700 divide-gray-200 dark:divide-gray-700 shadow-md dark:!border-gray-600 w-64 text-sm font-light">
        <div class="py-2 px-3 bg-gray-100 rounded-t-md border-b border-gray-200 dark:border-gray-600 dark:bg-gray-700">
            <h3 class="font-semibold text-gray-900 dark:text-white">Действие с выбранным</h3></div>

        {#if Object.keys(selected).length === 1 && getInfoByKey(selectedSlots[0])?.rest?.length}
            <div class="py-2 px-3">
                <Button color="primary" on:click={handleSplitGroupClick} size="xs">Разъединить группу</Button>
            </div>
            <hr/>
        {:else if allowCombine}
            <div class="py-2 px-3">
                {#if selectedSlotsSameType || selectedType}
                    <Checkbox bind:checked={combineToGroup}>Объединить в группу</Checkbox>
                {:else}
                    У выбранных слотов разные типы, для объединения выбертите тип
                {/if}

            </div>
            <hr/>
        {/if}

        <div class="py-2 px-3">
            {#each types as type}
                <div class="pb-1">
                <Radio name="selectedType" bind:group={selectedType} value={type}>{type.label}</Radio>
                </div>
            {/each}

        </div>
        <hr/>

        {#if selectedHasDifferentTags}
            <div class="py-2 px-3">
                У выбранных слотов разные теги, выберите общие:
            </div>
        {/if}
        <div class="py-2 px-3">
            <div class="pb-2 text-xs">Инструкторы:</div>
            {#each tags as tag}
                <div class="pb-1">
                <Checkbox bind:checked={tagsCheckBoxes[tag.value]} on:change={(e)=>handleTagChange(tag,e.target)}>{tag.name}</Checkbox>
                </div>
            {/each}
            </div>


        <hr/>

        <div class="py-2 px-3"><Input id="slot-comment" bind:value={comment} size="sm" placeholder="Комментарий"/></div>
        <hr/>
        <div class="py-2 px-3">
            <Button color="primary" on:click={handleApplyClick} size="xs" class="w-full">Применить</Button>
        </div>

    </div>

    <div class="flex  my-2 gap-2 items-center" style="zoom: 0.8; margin-left: 80px;">

        {#each tags as tag}
            <a href={undefined} on:click={()=>handleTagClick(tag)} class="cursor-pointer">
                <Badge color="{selectedTag===tag?'red':'dark'}" border class="text-xs">{tag.name}</Badge>
            </a>
        {/each}
    </div>



    {#if debugMode}


    <div class="mt-2 text-gray-500" style="font-size: 8px">
        <pre>checkboxes: {JSON.stringify(tagsCheckBoxes)}</pre>
    </div>
    <div class="mt-2 text-gray-500" style="font-size: 8px">
        <pre>selectedSlots: {JSON.stringify(selectedSlots)}</pre>
    </div>
    <div class="mt-2 text-gray-500" style="font-size: 8px">
        <pre>selectedTags: {JSON.stringify(selectedTags)}</pre>
    </div>

    <div class="mt-2 text-gray-500" style="font-size: 8px">
        {#each Object.keys(slotsInfo).sort() as key}
            <pre>{key}: {JSON.stringify(slotsInfo[key])}</pre>
        {/each}
    </div>
    {/if}


</main>

<script>
  import {onMount} from 'svelte';
  import {Accordion, AccordionItem, Badge, Button, Checkbox, Input, MultiSelect, Popover, Radio} from "flowbite-svelte";
  import {apiService} from "../lib/api.js";

  let tagsCheckBoxes = {};

  let fromDate = new Date()
  fromDate.setDate(fromDate.getDate()-1)
  let minDate = fromDate.toJSON().slice(0, 10)
  let toDate = new Date()
  toDate.setMonth(toDate.getMonth()+1)
  let maxDate = toDate.toJSON().slice(0, 10)

  // TODO: добавить смещение по дням
  // TODO: добавить возможность выделять на мобильном устройстве
  // TODO: сохранять данные в базу

  let selectedTags = []
  let selectedTag = undefined

  let menuPosition = {x: -1000, y: -1000};
  let canvas;

  const oddFill = '#ebe6e0'
  const evenFill = '#fcf7f1'

  const paddingLeft = 65
  const slotSize = 20;
  const workHours = 16
  const weekPadding = 4
  const defaultTextColor = '#aaa';
  const defaultSlotBorderColor = '#777';

  function handleTagChange(tag, target) {
    if (target.checked) {
      selectedTags.push(tag.value)
    } else {
      selectedTags = selectedTags.filter(t => t !== tag.value)
    }
  }

  let main = document.getElementById('main');

  const canvasWidth = workHours * 4 * slotSize + paddingLeft

  let combineToGroup = true;
  let selectedType = undefined;
  let comment = undefined;

  let days = []
  const today = new Date()
  let startDate = new Date(today.getFullYear(), today.getMonth(), 1)

  let selectedHasDifferentTags = false;

  const tags = [
    {value: 1, name: 'Иванов И.И.'},
    {value: 2, name: 'Петров П.П.'},
    {value: 3, name: 'Васильева Е.Е.'},
    {value: 4, name: 'Сидорова А.Б'},
  ]

  const slotsInfo = {}

  function getDateString(d) {
    const year = d.getFullYear(); // Get the year (e.g., 2023)
    const month = (d.getMonth() + 1).toString().padStart(2, '0'); // Get the month (0-11) and add 1, then pad with leading zero if needed
    const day = d.getDate().toString().padStart(2, '0'); // Get the day of the month and pad with leading zero if needed

    return `${year}-${month}-${day}`
  }

  function handleDateChange(){
    fromDate = new Date(minDate)
    toDate = new Date(maxDate)


    const loc_days = []
    for (let i = 0; i < 35; i++) {
      const d = new Date(fromDate.getTime() + (i * 24 * 60 * 60 * 1000));
      const key = getDateString(d)
      loc_days.push({
        key,
        label: d.toLocaleDateString('ru-RU', {weekday: 'short', day: 'numeric', month: 'short'}),
        date: d,
        slots: []
      })
    }
    days = loc_days

    for (let day of days) {
      for (let i = 0; i < 16; i++) {
        for (let j = 0; j < 4; j++) {
          const hour = i + 8;
          const minute = j * 15;
          const length = 1;// Math.round(Math.random()*2)+1;
          const label = minute.toString();
          console.log(day)
          const str_date = day.date.toISOString().split('T')[0]
          day.slots.push({
            key: `${str_date} ${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`,
            label,
            hour,
            minute,
            length
          });
        }
      }
    }

    render()

  }
  //
  // function handleWeekMove(delta) {
  //   startDate = new Date(startDate.getTime() + (7 * delta * 24 * 60 * 60 * 1000));
  //   const loc_days = []
  //   for (let i = 0; i < 24; i++) {
  //     const d = new Date(startDate.getTime() + (i * 24 * 60 * 60 * 1000));
  //     const key = getDateString(d)
  //     loc_days.push({
  //       key,
  //       label: d.toLocaleDateString('ru-RU', {weekday: 'short', day: 'numeric', month: 'long'}),
  //       date: d,
  //       slots: []
  //     })
  //   }
  //   days = loc_days
  // }
  //
  // handleWeekMove(0)

  function handleTagClick(tag) {
    if (selectedTag === tag) {
      selectedTag = undefined
    } else {
      selectedTag = tag
    }
    selected = {}
    render()
  }


  let menuEl;

  let selectedSlotsSameType = false;

  $: allowCombine = Object.keys(selected).length > 1
  $: selectedSlots = Object.keys(selected).length ? getSelectedSlotsKeys() : []




  function hideMenu() {
    menuPosition.x = -1000;
    menuPosition.y = -1000;
  }


  function handleSplitGroupClick() {
    splitSelectedSlots()
    render()

  }

  function splitSelectedSlots() {

    const selectedSlots = getSelectedSlotsGroupedByDay()
    console.log('splitSelectedSlots IN', 'selectedSlots', selectedSlots)

    for (let day of selectedSlots) {
      const selectedSlots = day.slots
      // selected = {}

      for (let slotKey of selectedSlots) {
        let slot = getInfoByKey(slotKey)

        slot.length = 1
        delete slot.label

        selected[slotKey] = slot;

        if (!slot.rest) {
          continue
        }
        for (let key of slot.rest) {
          const r = getInfoByKey(key)
          r.length = 1
          delete r.h
          // r.label = r.minute.toString()
          r.label = r.i.m.toString()
          selected[key] = r;
          setInfoByKey(key, r)
        }
        delete slot.rest
        setInfoByKey(slotKey, slot)
      }
    }


  }

  function getInfoByKey(key) {
    if (!key) {
      throw new Error('getInfoByKey: key is not set')
    }
    let info = slotsInfo[key]
    if (!info) {
      const time = key.split(' ')[1]
      return {key, length: 1, i: {h: +time.split(':')[0], m: +time.split(':')[1]}}
    }
    return slotsInfo[key]
  }

  function setInfoByKey(key, value) {
    return slotsInfo[key] = value
  }


  function groupSelectedSlots() {
    for (let day of getSelectedSlotsGroupedByDay()) {
      const selectedSlotsKeys = day.slots

      let firstSlotKey = selectedSlotsKeys[0]
      let firstSlot = getInfoByKey(firstSlotKey)

      let lastSlotKey = selectedSlotsKeys[selectedSlotsKeys.length - 1]
      let lastSlot = getInfoByKey(lastSlotKey)

      let totalLength = firstSlot.length

      let restSlotsKeys = selectedSlotsKeys.slice(1)

      for (let slotKey of restSlotsKeys) {

        const slot = getInfoByKey(slotKey)

        totalLength += slot.length
        if (!firstSlot.rest) firstSlot.rest = []
        firstSlot.rest.push(slotKey)

        if (slot.rest) {
          for (let r of slot.rest) {
            firstSlot.rest.push(r)
          }
          delete slot.rest
        }
        slot.h = true
        setInfoByKey(slotKey, slot)

      }
      firstSlot.length = totalLength

      if (firstSlot.length < 3) {
        firstSlot.label = `${firstSlot.i.m.toString().padStart(2, '0')} - ${lastSlot.i.m.toString().padStart(2, '0')}`
      } else if (firstSlot.length < 4) {
        firstSlot.label = `${firstSlot.i.h.toString().padStart(2, '0')}:${firstSlot.i.m.toString().padStart(2, '0')}-${lastSlot.i.h.toString().padStart(2, '0')}:${lastSlot.i.m.toString().padStart(2, '0')}`
      } else {
        firstSlot.label = `${firstSlot.i.h.toString().padStart(2, '0')}:${firstSlot.i.m.toString().padStart(2, '0')} - ${lastSlot.i.h.toString().padStart(2, '0')}:${lastSlot.i.m.toString().padStart(2, '0')}`
      }
      setInfoByKey(firstSlotKey, firstSlot)

    }
  }


  function getSelectedSlotsKeys() {
    // TODO: simplify
    const selectedSlots = []
    for (let slot of Object.values(selected)) {
      for (let day of days) {
        const found = day.slots.find(s => s.key === slot.key)
        if (!found) {
          continue
        }
        selectedSlots.push(slot.key)
      }
    }
    return selectedSlots
  }


  function getSelectedSlotsGroupedByDay() {
    const slotDays = {}
    for (let slot of Object.values(selected)) {
      for (let day of days) {
        const found = day.slots.find(s => s.key === slot.key)
        if (!found) continue
        if (!slotDays[day.key]) slotDays[day.key] = []
        slotDays[day.key].push(found.key)
      }
    }
    const selectedSlots = []
    for (let d of Object.keys(slotDays)) {
      selectedSlots.push({date: d, slots: slotDays[d]})
    }
    return selectedSlots
  }

  function setValueToSelectedSlots(key, value) {
    for (let sKey of getSelectedSlotsKeys()) {
      const info = getInfoByKey(sKey)
      info[key] = value
      if (info.rest) {
        for (let rKey of info.rest) {
          const slot = getInfoByKey(rKey)
          slot[key] = value
          setInfoByKey(rKey, slot)
        }
      }
      setInfoByKey(sKey, info)
    }
  }

  function handleApplyClick() {

    if (selectedType) {
      setValueToSelectedSlots('type', selectedType.id)
    }


    if (combineToGroup && allowCombine) {
      if (!selectedSlotsSameType && !selectedType) {
        console.log('selectedType is not set')
      } else {
        groupSelectedSlots()
      }
    }

    setValueToSelectedSlots('comment', comment)

    setValueToSelectedSlots('tags', selectedTags)

    selected = {}

    render()
  }


  let types = []
  apiService.getTypes().then((a) => {
    types = a
  })


  let rectangles = [];
  let selected = {}

  function drawMenu() {

    if (Object.keys(selected).length === 0) {
      return
    }

    let firstSelected = {x: 0, y: 0};
    let lastSelected = {x: 0, y: 0};
    let lastSelectedTopRow = {x: 0, y: 0};

    Object.values(selected).forEach(rect => {

      if (firstSelected.x === 0 || rect.x < firstSelected.x) firstSelected = rect


      if (rect.x >= lastSelected.x && rect.y >= lastSelected.y) {
        lastSelected = rect
      }
      if (lastSelectedTopRow.y === 0 || (rect.x >= lastSelectedTopRow.x && rect.y <= lastSelectedTopRow.y)) {
        lastSelectedTopRow = rect
      }
    });


    selectedType = undefined;

    const comments = new Set()

    const selectedSlotsKeys = getSelectedSlotsKeys()

    const slotTypes = new Set()
    const slotTags = new Set()
    const allTags = new Set()

    selectedSlotsKeys.forEach(k => {
      const slot = getInfoByKey(k)
      if (slot.comment) {
        comments.add(slot.comment)
      }
      if (slot.type) {
        slotTypes.add(slot.type)
      }
      if (slot.tags) {
        slotTags.add(slot.tags.sort().join(' ').toString())
        for (let tag of slot.tags) {
          allTags.add(tag)
        }
      }
    })


    comment = undefined
    if (comments.size === 1) {
      comment = comments.values().next().value
    }

    selectedSlotsSameType = slotTypes.size < 2

    if (!selectedSlotsSameType) {
      selectedType = undefined
    }

    if (slotTypes.size === 1) {
      selectedType = getTypeById(slotTypes.values().next().value)
    }

    if (slotTags.size === 1) {
      selectedHasDifferentTags = false
      selectedTags = slotTags.values().next().value.split(' ').map(t => +t.trim())
    } else {
      if (slotTags.size === 0) {
        selectedTags = []
      } else {
        selectedTags = Array.from(allTags)
      }
    }

    selectedHasDifferentTags = slotTags.size > 1

    for (let key of Object.keys(tagsCheckBoxes)){
      tagsCheckBoxes[key] = false
    }

    for (let tag of selectedTags) {
      tagsCheckBoxes[tag] = true
    }


    const canvasPosition = canvas.getBoundingClientRect()

    const canLeftPad = canvasPosition.left + window.scrollX;
    const canTopPad = canvasPosition.top + window.scrollY;


    let x = canLeftPad + lastSelected.x - 48
    let y = canTopPad + lastSelected.y + 24


    if (x < 12) x = 12
    if (y < 12) y = 12

    const menuBoundData = menuEl.getBoundingClientRect()

    if (x + menuBoundData.width > canLeftPad + canvasPosition.width) {
      x = canLeftPad + canvasPosition.width - menuBoundData.width
    }

    /*
    if (y> canvasPosition.height*3/4){
      y = canTopPad + lastSelectedTopRow.y - menuBoundData.height
    }

    if (y<0){
      y = lastSelectedTopRow.y
      x=lastSelected.x + 40
    }

    if (x + menuBoundData.width > canLeftPad + canvasPosition.width) {
      x = firstSelected.x - menuBoundData.width
    }*/

    menuPosition.x = x
    menuPosition.y = y

    console.log('SHOWING MENU AT', menuPosition)


  }

  function findIntersections(selection) {
    const intersections = [];

    selected = {}


    function intersect(rect1, rect2) {
      return (
        rect1.x < rect2.x + rect2.width &&
        rect1.x + rect1.width > rect2.x &&
        rect1.y < rect2.y + rect2.height &&
        rect1.y + rect1.height > rect2.y
      );
    }

    for (let j = 0; j < rectangles.length; j++) {
      if (intersect(selection, rectangles[j])) {
        intersections.push(rectangles[j]);
      }
    }
    for (let r of intersections) {
      selected[r.key] = r;
    }

    return intersections;
  }


  function render() {
    hideMenu()
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    drawDates()
    drawHeader()
    drawTimeline()
  }

  function drawDates() {
    ctx.font = "11px Arial";
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    let y = weekPadding;
    for (let i = 0; i < days.length; i++) {
      const day = days[i]
      const dow = day.date.getDay()
      y +=20;
      // ctx.strokeStyle = 'black';
      // ctx.strokeRect(0, y,  paddingLeft, 20);
      ctx.fillStyle = '#000';

      if (dow === 6 || dow === 0 ){
        ctx.fillStyle = '#FF0000';
      }

      ctx.fillText(day.label, paddingLeft / 2, y + 12);

      if (selectedTag) {
        ctx.globalAlpha = 0.2
      }

      ctx.strokeStyle = '#ddd';
      // ctx.beginPath();
      // ctx.moveTo(1,y);
      // ctx.lineTo(1, y+20);
      // ctx.stroke();

      if (dow === 1) {
        ctx.beginPath();
        ctx.moveTo(1, y);
        ctx.lineTo(paddingLeft-4, y);
        ctx.stroke();
      }


      if (dow === 0) {
        ctx.beginPath();
          ctx.moveTo(1, y+20);
          ctx.lineTo(paddingLeft-4, y+20);
          ctx.stroke();
      }

      ctx.globalAlpha = 1

      if (dow === 0) {
        y+=weekPadding
      }
    }


  }

  function drawHeader() {
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.font = "16px Arial";
    const width = slotSize * 4
    const height = slotSize;
    ctx.strokeStyle = defaultSlotBorderColor;
    for (let i = 0; i < 16; i++) {
      ctx.fillStyle = i % 2 === 0 ? evenFill : oddFill;
      const x = paddingLeft + i * width;
      const y = 0;
      // ctx.fillRect(x, 0, width, height * (days.length + 1));
      // ctx.strokeStyle = 'black';
      ctx.fillRect(x, 0, width, height );
      ctx.strokeRect(x, 0, width, height );
      ctx.fillStyle = '#000000';
      ctx.fillText(i + 8, x + width / 2, y + height / 2);
    //   ctx.strokeStyle = 'black';
    //   ctx.beginPath();
    //   ctx.moveTo(x, y);
    //   ctx.lineTo(x, y + height);
    //   ctx.stroke();
    //   ctx.beginPath();
    //   ctx.moveTo(x, y);
    //   ctx.lineTo(width, y);
    //   ctx.stroke();
    }
  }

  function drawTimeline() {
    rectangles = []
    let y = weekPadding ;
    for (let i = 0; i < days.length; i++) {
      y+=20
      const day = days[i]
      drawOneLine(day, y)

      if (day.date.getDay() === 0) {
        y+=weekPadding
      }
    }
    ctx.globalAlpha = 1
  }

  function getTypeById(id) {
    return types.find(t => t.id === id)
  }

  function drawOneLine(day, y) {
    ctx.font = "11px Arial";
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';






    let i = 0;
    for (let daySlot of day.slots) {

      const info = getInfoByKey(daySlot.key)

      if (selectedTag) {
        ctx.globalAlpha = 0.2
        if (info.tags && info.tags.length > 0) {
          if (info.tags.includes(selectedTag.value)) {
            ctx.globalAlpha = 1
          }
        }
      }

      ctx.setLineDash([0]);
      if (info.h) {
        continue
      }
      ctx.lineWidth = 1
      const rect = {
        x: i * slotSize + paddingLeft,
        y: y,
        width: slotSize * info.length,
        height: slotSize,
        key: daySlot.key
      }
      i = i + info.length;

      let textColor = defaultTextColor;

      ctx.strokeStyle = defaultSlotBorderColor;

      ctx.fillStyle = info.i.h % 2 === 0 ? evenFill : oddFill;
      ctx.fillRect(rect.x, rect.y, rect.width, rect.height);



      if (info.type) {
        const type = getTypeById(info.type)
        ctx.fillStyle = type.color;
        ctx.fillRect(rect.x, rect.y, rect.width, rect.height);
        textColor = '#ffffff';
        ctx.strokeStyle = 'black';
      }

      if (selected[daySlot.key]) {
        textColor = '#000';
        ctx.fillStyle = '#00ff00';
        ctx.fillRect(rect.x, rect.y, rect.width, rect.height);
        ctx.setLineDash([4, 2]);
      }

      ctx.strokeRect(rect.x, rect.y, rect.width, rect.height);
      const textX = rect.x + rect.width / 2;
      const textY = rect.y + rect.height / 2 + 1;
      ctx.fillStyle = textColor;
      ctx.fillText(info.label || daySlot.label, textX, textY);

      if (daySlot.minute === 0) {
        ctx.setLineDash([0]);
        ctx.strokeStyle = 'black';
        ctx.beginPath();
        ctx.moveTo(rect.x, rect.y);
        ctx.lineTo(rect.x, rect.y + rect.height);
        ctx.stroke();

      }

      rectangles.push(rect);
    }
  }

  let ctx;

  let isDrawing = false;
  let startX, startY;

  let prevSelection;

  function onMousseUp(e) {
    if (!isDrawing) return;
    isDrawing = false;
    const mouseX = e.layerX - canvas.offsetLeft;
    const mouseY = e.layerY - canvas.offsetTop;
    const width = mouseX - startX;
    const height = mouseY - startY;

    const selection = ({x: startX, y: startY, width, height});

    if (selection.width < 0) {
      selection.x = selection.x + selection.width;
      selection.width = -selection.width;
    }

    if (selection.height < 0) {
      selection.y = selection.y + selection.height;
      selection.height = -selection.height;
    }
    findIntersections(selection);

    const selectedStr = JSON.stringify(selected);

    if (selectedStr === prevSelection) {
      selected = {};
      prevSelection = null;
      render();
      return;
    }

    prevSelection = selectedStr;


    render();
    drawMenu();

  };

  function onMousseMove(e) {
    if (!isDrawing) return;

    const mouseX = e.layerX - canvas.offsetLeft;
    const mouseY = e.layerY - canvas.offsetTop;

    const width = mouseX - startX;
    const height = mouseY - startY;

    render();
    ctx.strokeStyle = 'blue';
    ctx.strokeRect(startX, startY, width, height);
  }


  function beforeRender() {


    ctx = canvas.getContext('2d');
    if (window.devicePixelRatio > 1) {
      // const ratio = window.devicePixelRatio
      const ratio = 4
      const canvasWidth = canvas.width;
      const canvasHeight = canvas.height;
      canvas.width = canvasWidth * ratio;
      canvas.height = canvasHeight * ratio;
      canvas.style.width = canvasWidth + "px";
      canvas.style.height = canvasHeight + "px";
      ctx.scale(ratio, ratio);
    }


    canvas.addEventListener('mousedown', (e) => {
      hideMenu()

      isDrawing = true;
      startX = e.layerX - canvas.offsetLeft;
      startY = e.layerY - canvas.offsetTop;
    });

    // canvas.addEventListener('mousemove', onMousseMove);

    // canvas.addEventListener('mouseup', onMousseUp);
    // canvas.addEventListener('mouseout', onMousseUp);


  }

  let debugMode = false;

  onMount(() => {
    debugMode = window.location.hash.indexOf('debug')>-1
    beforeRender();
    handleDateChange();
    main.addEventListener('mouseup', onMousseUp);
    main.addEventListener('mousemove', onMousseMove);
  });
</script>