// ** MUI Imports
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Button from '@mui/material/Button'
import Avatar from '@mui/material/Avatar'
import CardMedia from '@mui/material/CardMedia'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'
import AvatarGroup from '@mui/material/AvatarGroup'
import Image from 'next/image'

const NftSaleCard = ({ image }) => {
  return (
    <Card sx={{ position: 'relative' }}>
        <CardMedia sx={{ height: 178 }} image={`/images/nft/azuki/${image}.png`} />
        <CardContent>
            <Box
                sx={{
                    mb: 5.25,
                    display: 'flex',
                    flexWrap: 'wrap',
                    alignItems: 'center',
                    justifyContent: 'space-between'
                }}
            >
                <Box sx={{ mr: 2, mb: 1, display: 'flex', flexDirection: 'column' }}>
                    <Typography variant='h6'>AZUKI #{image}</Typography>
                </Box>
                
                <Box sx={{ gap: 2, display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'center', width: '100%' }}>
                    <Typography variant='body1' sx={{ whiteSpace: 'nowrap', display: 'flex', alignItems: 'center' }}>
                        150 <Image src='/images/coins/com.svg' width={30} height={32} alt='$COM' style={{ marginLeft: 4 }} />
                    </Typography>
                    <Button variant='contained'>Buy Now</Button>
                </Box>
            </Box>
        </CardContent>
    </Card>
  )
}

export default NftSaleCard
