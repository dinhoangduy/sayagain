import Link from "next/link";
import type { CardFollowUp } from "@/lib/episodes/schema";

/**
 * Lists the next questions under a card and links each one to its practice deck.
 * @param props.followUps - Up to three branches from the scenario bank.
 * @returns The question list, or null when this card has no branches.
 */
export function FollowUpQuestions({
  followUps,
}: {
  followUps: CardFollowUp[] | null | undefined;
}) {
  if (!followUps?.length) {
    return null;
  }

  return (
    <div className="mt-6 border-t border-[#edf2ef] pt-5">
      <p className="text-xs font-semibold tracking-wide text-[#52635a] uppercase">
        Follow-up questions
      </p>
      <ol className="mt-3 space-y-4">
        {followUps.map((followUp, index) => (
          <li key={`${followUp.speaker}-${index}`}>
            <p className="text-sm leading-relaxed font-semibold text-[#132019]">
              <span className="text-[#146c43]">
                {index + 1}. {followUp.speaker}:
              </span>{" "}
              “{followUp.question}”
            </p>
            <div className="mt-1.5 flex flex-col gap-1">
              {followUp.decks.map((deck) => (
                <Link
                  key={deck.code}
                  href={`/import/${deck.code}`}
                  className="text-sm font-semibold text-[#146c43] underline decoration-[#c8e3d2] underline-offset-2 hover:decoration-[#146c43]"
                >
                  {deck.code} · {deck.phrase}
                </Link>
              ))}
            </div>
          </li>
        ))}
      </ol>
    </div>
  );
}
