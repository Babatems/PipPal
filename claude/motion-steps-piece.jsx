const { CompositionStage, useComposition, Easing, animate } = window;

const W = 1080, H = 1080;
// mark content spans x30..113, y-1..117 — scaled 6x and centred in the stage
const S = 6, TX = 111, TY = 192;

const INK = '#2D2D2A', CRIMSON = '#C14953';

// exactly three motion helpers; no easing or transform is authored outside them
const MOTION = {
  rise:  (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutExpo }),
  glide: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutQuart }),
  bloom: (from, to, start, end) => animate({ from, to, start, end, ease: Easing.easeOutCubic })
};

function Piece() {
  const { T, CUES } = useComposition();

  // 1 — the stem rises from below the frame and settles on centre
  const stemY = MOTION.rise(172, 0, CUES.Stem + 0.04, CUES.Stem + 0.66)(T);

  // 2 — the bowl glides in from beyond the right edge, overlapping the stem's settle
  const bowlX = MOTION.glide(138, 0, CUES.Bowl - 0.1, CUES.Bowl + 0.56)(T);

  // 3 — the candle blooms in place, lifting a touch as it arrives
  const candleO = MOTION.bloom(0, 1, CUES.Candle + 0.02, CUES.Candle + 0.44)(T);
  const candleY = MOTION.bloom(10, 0, CUES.Candle + 0.02, CUES.Candle + 0.52)(T);

  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`}>
      <g transform={`translate(${TX} ${TY}) scale(${S})`}>
        <g transform={`translate(0 ${stemY})`}>
          <path d="M32 2 H52 V100 L32 116 Z" fill={INK}></path>
        </g>
        <g transform={`translate(${bowlX} 0)`}>
          <path d="M52 14 A35 35 0 0 1 52 84 L52 64 A15 15 0 0 0 52 34 Z" fill={INK}></path>
        </g>
        <g transform={`translate(0 ${candleY})`} opacity={candleO}>
          <rect x="98" y="22" width="4" height="54" fill={CRIMSON}></rect>
          <rect x="89" y="34" width="22" height="30" fill={CRIMSON}></rect>
        </g>
      </g>
    </svg>
  );
}

function MotionSteps() {
  return (
    <CompositionStage
      width={W}
      height={H}
      scenes={window.OM_SCENES}
      playback={window.OM_PLAYBACK}
      bg="#F5F1E8"
    >
      <Piece />
    </CompositionStage>
  );
}

window.MotionSteps = MotionSteps;
