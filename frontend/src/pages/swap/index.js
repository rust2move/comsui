import { Box } from "@mui/system"
import SwapView from "src/views/swap/Swap"

const Swap = () => {
  return (
    <Box
        sx={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            height: '100%'
        }}
    >
        <SwapView />
    </Box>
  )
}

export default Swap
