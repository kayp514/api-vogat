import { NextResponse } from 'next/server'
import { getAllWorkspaces } from '@/lib/db/queries'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const maxResults = searchParams.get('maxResults')
    const nextPage = searchParams.get('nextPage')

    const result = await getAllWorkspaces(
      maxResults ? parseInt(maxResults) : undefined,
      nextPage ? parseInt(nextPage) : undefined
    )

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      workspaces: result.workspaces,
      totalCount: result.totalCount,
      totalPages: result.totalPages,
      currentPage: result.currentPage,
      hasMore: result.hasMore
    })

  } catch (error) {
    console.error('Workspace API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to fetch workspaces'
        }
      },
      { status: 500 }
    )
  }
}