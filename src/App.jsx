import { createResource, createSignal } from 'solid-js'
import solidLogo from './assets/solid.svg'
import viteLogo from '/vite.svg'
import './App.css'
import './slot.css'


const hours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
const monthes = ['января', 'февраля', 'марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря']


function formatTime(date) {
  let hours = date.getHours();
  let minutes = date.getMinutes();
  // hours = (hours < 10) ? "0" + hours : hours;
  minutes = (minutes < 10) ? "0" + minutes : minutes;
  return [hours, minutes]
}

async function fetchData() {
  return fetch('https://api.x125.ru/rnd/slots/get').then(a => a.json())
}

async function setState(date,slot){
  fetch('https://api.x125.ru/rnd/slots/state/set', {
    method: 'POST',
    body: JSON.stringify({date, num: slot.num, state:slot.state})
  })

}

function classByState(state) {
  switch (state) {
    case 'FREE': return 'free'
    case 'FREE_RIDE': return 'free-ride'
    case 'BOOKED': return 'booked'
    case 'TECH': return 'tech'
  }

}


function App() {
  const [count, setCount] = createSignal(0)

  const [data, { mutate }] = createResource(fetchData)

  const [selectedState, setSelectedState] = createSignal()

  function handleSelectState(state) {
    setSelectedState(state)
  }



  function renderSlots(date, slots) {

    return slots.map(a => {
      let cls = "slot " + classByState(a.state)
      if (a.hour % 2 == 0) { cls += ' even' }
      if (a.min == 0) { cls += ' start' }

      return <div class={cls} onClick={() => {

        if (!selectedState()) { return }

        if (a.state == selectedState()) {
          a.state = 'FREE'
        } else {
          a.state = selectedState()
        }

        setState(date,a)
        mutate(Object.assign([], data()))
      }}>
        <div class="item">{a.min}</div>
      </div>
    })
  }

  function dateFormat(date){
    // monthes[currentDate.getMonth()]{
      // date = new Date(date)
      date = new Date(date)
    return date.getDate() + ' ' + monthes[date.getMonth()]
  }

  function renderLine(row) {
    return <div class="day">
      <div class="date">{dateFormat(row.date)}</div>
      <div class="slots">
        {renderSlots(row.date, row.slots)}
      </div>
    </div>
  }

  function renderStateSelectButton(state, title) {
    let cls = classByState(state)
    cls += ' legend'
    if (selectedState() == state) {
      cls += ' selected'
    }
    return <div class={cls} onClick={() => handleSelectState(state)}>{title}</div>
  }


  return <>
    <div style="display:flex; margin-bottom:10px; justify-content:center; gap:4px;">
      {renderStateSelectButton('FREE', 'свободно')}
      {renderStateSelectButton('FREE_RIDE', 'свободное катание')}
      {renderStateSelectButton('BOOKED', 'бронь')}
      {renderStateSelectButton('TECH', 'технический перерыв')}
    </div>
    <div class="day">
      <div class="date"></div>
      <div style=" display:flex; ">
        {hours.map(a => <div style="border-top:1px solid gray; font-size:0.9em; border-left:2px solid black; width:78px;">{a}</div>)}
      </div>
    </div>
    <div class="slots-pane">
      <Show when={data()} fallback={<div>Loading…</div>}>
        {data().map(row => renderLine(row))}
      </Show>
    </div>
  </>
}

export default App
