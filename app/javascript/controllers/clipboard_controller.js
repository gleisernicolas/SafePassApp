import { Controller } from "@hotwired/stimulus";
import { checkIcon, cipboardIcon } from "../utils/icons";
class ClipbardController extends Controller {
  async copy({params: { content }}){
    try {
      await navigator.clipboard.writeText(content)
      this.element.innerHTML = checkIcon
      setTimeout(() => {
        this.element.innerHTML = cipboardIcon
      }, 500)

    } catch (e) {
      console.error(e)
    }
  }
}

export default ClipbardController