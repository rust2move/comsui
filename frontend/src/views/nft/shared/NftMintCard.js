// ** MUI Imports
import Box from '@mui/material/Box'
import Card from '@mui/material/Card'
import Button from '@mui/material/Button'
import Avatar from '@mui/material/Avatar'
import CardMedia from '@mui/material/CardMedia'
import Typography from '@mui/material/Typography'
import CardContent from '@mui/material/CardContent'
import AvatarGroup from '@mui/material/AvatarGroup'

const NftMintCard = ({ image }) => {
  return (
    <Card sx={{ position: 'relative' }}>
      <CardMedia sx={{ height: 178 }} image={`/images/nft/collection/${image}`} />
      <Avatar
        alt='Robert Meyer'
        src={`/images/avatars/${Math.floor(Math.random() * 8) + 1}.png`}
        sx={{
          top: 139,
          left: 20,
          width: 78,
          height: 78,
          position: 'absolute',
          border: theme => `5px solid ${theme.palette.common.white}`
        }}
      />
      <CardContent>
        <Box
          sx={{ display: 'flex', justifyContent: 'space-between' }}
        >
          <Box
            sx={{
              mt: 5.75,
              mb: 5.25,
              display: 'flex',
              flexWrap: 'wrap',
              alignItems: 'center',
              justifyContent: 'space-between'
            }}
          >
            <Box sx={{ mr: 2, mb: 1, display: 'flex', flexDirection: 'column' }}>
              <Typography variant='body2'>Robert Meyer</Typography>
              <Typography variant='caption'>London, UK</Typography>
            </Box>
          </Box>
          <Box>
            <Typography variant='h6'>Webacy Safety Pass</Typography>
          </Box>
        </Box>
        <Box sx={{ gap: 2, display: 'flex', flexWrap: 'wrap', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant='overline' sx={{ whiteSpace: 'nowrap' }}>
            End in:  01d 14h 09m
          </Typography>
          <Button variant='contained'>Mint Now</Button>
        </Box>
      </CardContent>
    </Card>
  )
}

export default NftMintCard
