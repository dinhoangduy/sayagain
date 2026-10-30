export const NEW_CARD_LIMIT = 5;

/**
 * Counts cards the learner has never graded. FSRS state 0 is New.
 * @param states - `fsrs_state` values from the on-device collection.
 * @returns How many of those cards are still new.
 */
export function countNewCards(states: readonly number[]): number {
  return states.reduce((total, state) => total + (state === 0 ? 1 : 0), 0);
}

/**
 * Cards an import would insert. Cards already in the collection are not new again.
 * @param cardCount - Cards in the published deck.
 * @param alreadyOwned - Cards from that deck already stored for this learner.
 * @returns How many new cards this import would add.
 */
export function cardsThatWouldBeNew(cardCount: number, alreadyOwned: number): number {
  return Math.max(0, cardCount - Math.max(0, alreadyOwned));
}

/**
 * Allows a re-check of a deck the learner already owns. Blocks any insert past the cap.
 * @param currentNew - New cards already in the collection.
 * @param adding - New cards this import would insert.
 * @param limit - Maximum new cards one learner may hold.
 * @returns Whether the import may add those cards.
 */
export function canAddNewCards(
  currentNew: number,
  adding: number,
  limit = NEW_CARD_LIMIT,
): boolean {
  if (adding <= 0) return true;
  return currentNew + adding <= limit;
}

/**
 * Explains why an import is closed. A null result means the import can proceed.
 * @param currentNew - New cards already in the collection.
 * @param adding - New cards this import would insert.
 * @param limit - Maximum new cards one learner may hold.
 * @returns Learner-facing reason, or null when the import fits.
 */
export function newCardImportBlockReason(
  currentNew: number,
  adding: number,
  limit = NEW_CARD_LIMIT,
): string | null {
  if (canAddNewCards(currentNew, adding, limit)) return null;
  if (currentNew >= limit) {
    return `You already have ${limit} new cards. Practice them before importing more.`;
  }
  const open = Math.max(0, limit - currentNew);
  const slotLabel = open === 1 ? "slot" : "slots";
  return `This deck adds ${adding} new cards, and you have ${open} open ${slotLabel}.`;
}
