import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class GamificationRankConnector extends Component {
  @tracked userRank = null;

  constructor() {
    super(...arguments);
    this.id = settings.leaderboard_id || 1;
    this.timeframe = settings.leaderboard_timeframe || "all_time";
    this.cutoff =
      settings.leaderboard_rank_cutoff === 0
        ? null
        : settings.leaderboard_rank_cutoff;
    this.loadRank();
  }

  @action
  async loadRank() {
    const user = this.args.user;
    if (!user) {
      this.userRank = null;
      return;
    }

    try {
      const result = await ajax(
        `/leaderboard/${this.id}?period=${this.timeframe}`
      );
      const found = result.users.find((u) => u.username === user.username);
      this.userRank = found ? found.position : null;
    } catch (error) {
      console.warn(
        "Leaderboard URL is not valid. Make sure the leaderboard ID is correct.",
        error
      );
      this.userRank = null;
    }
  }

  get hasValidRank() {
    if (!this.userRank || this.userRank === "null") {
      return false;
    }

    if (this.cutoff && Number(this.userRank) > Number(this.cutoff)) {
      return false;
    }
    return true;
  }

  <template>
    {{#if this.hasValidRank}}
      <div class="user-card-metadata-outlet gamification-rank">
        <span class="desc">{{i18n "gamification.leaderboard.rank"}}</span>
        <span class="gamification-rank">{{this.userRank}}</span>
      </div>
    {{/if}}
  </template>
}
