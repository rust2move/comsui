// ** MUI Imports
import Card from '@mui/material/Card'
import CardHeader from '@mui/material/CardHeader'
import CardContent from '@mui/material/CardContent'
import { useTheme } from '@mui/material/styles'

// ** Third Party Imports
import { Line } from 'react-chartjs-2'

import 'chart.js/auto'


const PriceChart = () => {
  const theme = useTheme()
  
  const white = '#fff'
  const primary = '#836af9'
  const success = '#d4e157'
  const warning = '#ffbd1f'
  const legendColor = theme.palette.text.secondary
  const borderColor = theme.palette.divider
  const labelColor = theme.palette.text.disabled

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      x: {
        ticks: { color: labelColor },
        grid: {
          color: borderColor
        }
      },
      y: {
        min: 0,
        max: 400,
        ticks: {
          stepSize: 100,
          color: labelColor
        },
        grid: {
          color: borderColor
        }
      }
    },
    plugins: {
      legend: {
        align: 'end',
        position: 'top',
        labels: {
          padding: 25,
          boxWidth: 10,
          color: legendColor,
          usePointStyle: true
        }
      }
    }
  }

  const data = {
    labels: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140],
    datasets: [
      {
        fill: false,
        tension: 0.5,
        pointRadius: 1,
        label: 'ComSwap Sell',
        pointHoverRadius: 5,
        pointStyle: 'circle',
        borderColor: warning,
        backgroundColor: warning,
        pointHoverBorderWidth: 5,
        pointHoverBorderColor: white,
        pointBorderColor: 'transparent',
        pointHoverBackgroundColor: warning,
        data: [80, 150, 180, 270, 210, 160, 160, 202, 265, 210, 270, 255, 290, 360, 375]
      },
      {
        fill: false,
        tension: 0.5,
        pointRadius: 1,
        label: 'ComSwap Buy',
        pointHoverRadius: 5,
        pointStyle: 'circle',
        borderColor: primary,
        backgroundColor: primary,
        pointHoverBorderWidth: 5,
        pointHoverBorderColor: white,
        pointBorderColor: 'transparent',
        pointHoverBackgroundColor: primary,
        data: [80, 99, 82, 90, 115, 115, 74, 75, 130, 155, 125, 90, 140, 130, 180]
      },
      {
        fill: false,
        tension: 0.5,
        label: 'Uniswap',
        pointRadius: 1,
        pointHoverRadius: 5,
        pointStyle: 'circle',
        borderColor: success,
        backgroundColor: success,
        pointHoverBorderWidth: 5,
        pointHoverBorderColor: white,
        pointBorderColor: 'transparent',
        pointHoverBackgroundColor: success,
        data: [80, 125, 105, 130, 215, 195, 140, 160, 230, 300, 220, 170, 210, 200, 280]
      },
    ]
  }

  return (
    <Card>
      <CardHeader title='$COM Price Chart' subheader='Feed from comswap.io and uniswap.org' />
      <CardContent>
        <Line data={data} height={400} options={options} />
      </CardContent>
    </Card>
  )
}

export default PriceChart
