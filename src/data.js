const zones = [
  {
    value: 1, name: 'Ледовая арена',
    types: [
      {
        "id": 1,
        "label": "Свободное катание",
        "color": "rgb(63, 131, 248)"
      },
      {
        "id": 2,
        "label": "Тренировка дети",
        "color": "rgb(14, 159, 110)"
      },
      {
        "id": 3,
        "label": "Тренировка взрослые",
        "color": "rgb(6, 182, 212)"
      },
      {
        "id": 4,
        "label": "Технический перерыв",
        "color": "rgb(100, 100, 100)"
      },
      {
        "id": 5,
        "label": "Внутренний резерв",
        "color": "rgb(6, 148, 162)"
      }
    ],
    tags: [
      {value: 1, name: 'Иванов И.И.'},
      {value: 2, name: 'Петров П.П.'},
      {value: 3, name: 'Васильева Е.Е.'},
      {value: 4, name: 'Сидорова А.Б'},
    ]
  },
  {
    value: 2, name: 'Бассейн: дорожка 1',
    types: [
      {
        "id": 6,
        "label": "Свободное плавание",
        "color": "rgb(63, 131, 248)"
      },
      {
        "id": 7,
        "label": "Групповая: дети",
        "color": "rgb(14, 159, 110)"
      },
      {
        "id": 8,
        "label": "Групповая: взрослые",
        "color": "rgb(6, 182, 212)"
      },
      {
        "id": 9,
        "label": "Персональная: дети",
        "color": "rgb(250, 14, 110)"
      },
      {
        "id": 10,
        "label": "Персональная: взрослые",
        "color": "rgb(126, 182, 212)"
      },
      {
        "id": 11,
        "label": "Технический перерыв",
        "color": "rgb(100, 100, 100)"
      }],
    tags: [
      {value: 5, name: 'Пых Т.У.'},
      {value: 6, name: 'Инвертер Г.А.'},
      {value: 7, name: 'Дуло Е.В.'},
    ]
  },
  {value: 3, name: 'Бассейн: дорожка 2', types: [], tags: []},
  {value: 4, name: 'Бассейн: дорожка 3', types: [], tags: []},
]

export function getZones() {
  return Promise.resolve(zones)
}