// ** Mock Adapter
import mock from 'src/@fake-db/mock'

const searchData = [
  {
    id: 1,
    url: '/',
    icon: 'mdi:chart-donut',
    title: 'Dashboard',
    category: 'dashboards'
  },
  {
    id: 2,
    url: '/swap',
    icon: 'iconoir:coins-swap',
    title: 'SWAP',
    category: 'dashboards'
  },
  {
    id: 3,
    url: '/nft/launchpad',
    icon: 'mdi:rocket-launch-outline',
    title: 'NFT Launchpad',
    category: 'dashboards'
  },
  {
    id: 4,
    url: '/nft/trade',
    icon: 'gravity-ui:shopping-cart',
    title: 'NFT Buy & Sell',
    category: 'dashboards'
  },
]

// ** GET Search Data
mock.onGet('/app-bar/search').reply(config => {
  const { q = '' } = config.params
  const queryLowered = q.toLowerCase()

  const exactData = {
    dashboards: [],
    appsPages: [],
    userInterface: [],
    formsTables: [],
    chartsMisc: []
  }

  const includeData = {
    dashboards: [],
    appsPages: [],
    userInterface: [],
    formsTables: [],
    chartsMisc: []
  }
  searchData.forEach(obj => {
    const isMatched = obj.title.toLowerCase().startsWith(queryLowered)
    if (isMatched && exactData[obj.category].length < 5) {
      exactData[obj.category].push(obj)
    }
  })
  searchData.forEach(obj => {
    const isMatched =
      !obj.title.toLowerCase().startsWith(queryLowered) && obj.title.toLowerCase().includes(queryLowered)
    if (isMatched && includeData[obj.category].length < 5) {
      includeData[obj.category].push(obj)
    }
  })
  const categoriesCheck = []
  Object.keys(exactData).forEach(category => {
    if (exactData[category].length > 0) {
      categoriesCheck.push(category)
    }
  })
  if (categoriesCheck.length === 0) {
    Object.keys(includeData).forEach(category => {
      if (includeData[category].length > 0) {
        categoriesCheck.push(category)
      }
    })
  }
  const resultsLength = categoriesCheck.length === 1 ? 5 : 3

  return [
    200,
    [
      ...exactData.dashboards.concat(includeData.dashboards).slice(0, resultsLength),
      ...exactData.appsPages.concat(includeData.appsPages).slice(0, resultsLength),
      ...exactData.userInterface.concat(includeData.userInterface).slice(0, resultsLength),
      ...exactData.formsTables.concat(includeData.formsTables).slice(0, resultsLength),
      ...exactData.chartsMisc.concat(includeData.chartsMisc).slice(0, resultsLength)
    ]
  ]
})
